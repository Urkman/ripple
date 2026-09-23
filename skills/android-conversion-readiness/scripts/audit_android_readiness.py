#!/usr/bin/env python3
"""Static prerequisite audit for the Ripple Android conversion handoff.

This script intentionally reports findings; it does not modify the repository
or decide product behavior. It is useful before Android implementation starts,
when the Android implementation repository is separate from this repository.
"""

from __future__ import annotations

import argparse
import json
import re
import struct
import sys
import xml.etree.ElementTree as ET
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


EXPECTED_SURFACE_COUNT = 22

REQUIRED_FILES = (
    "AGENTS.md",
    "Docs/shared/Ripple_PRD.md",
    "Docs/shared/Ripple_SCREEN_CATALOG.md",
    "Docs/shared/Ripple_DESIGN_SYSTEM.md",
    "Docs/shared/Ripple_DATA_MODEL.md",
    "Docs/shared/IOS_ARCHITECTURE.md",
    "Docs/shared/Android/ANDROID_ARCHITECTURE.md",
    "Docs/shared/Android/ANDROID_UI_SPEC.md",
    "Docs/shared/Android/UI/README.md",
    "Docs/shared/wireframes/README.md",
    "Docs/shared/Ripple_VISUAL_REFERENCE_INVENTORY.md",
)

REQUIRED_SURFACE_SECTIONS = (
    "Reference evidence and visible-element inventory",
    "Platform-independent wireframes",
    "Timeline",
    "Related contracts",
)

FORBIDDEN_CANONICAL_TERMS = (
    "SwiftUI",
    "UIKit",
    "Jetpack Compose",
    "Compose",
    "Material",
    "SwiftData",
    "CloudKit",
    "HealthKit",
    "WidgetKit",
    "TimelineView",
    "Core Motion",
)

DESIGN_SYSTEM_TERMS = (
    "RippleColor",
    "RippleFont",
    "RippleSpace",
    "RippleLayout",
    "RippleRadius",
    "RippleMotion",
    "native-control",
    "Reduce Motion",
)

ANDROID_ACCEPTANCE_TERMS = (
    "Definition of UI complete",
    "four chart",
    "seven-day",
    "Reduce Motion",
    "TalkBack",
    "native",
)

STYLE_PATTERNS = (
    ("color", re.compile(r"\bColor\s*\(|\bColor\.(?:white|black|red|blue|green|yellow|orange|purple|gray|primary|secondary)\b|#(?:[0-9A-Fa-f]{3,8})\b|\bUIColor\b")),
    ("font", re.compile(r"\.font\(\s*\.(?:largeTitle|title|title2|title3|headline|subheadline|body|callout|caption|caption2|footnote)\b|Font\.(?:system|custom)\b")),
    ("layout", re.compile(r"\.(?:padding|frame|offset)\([^)]*\b(?:width|height|minWidth|minHeight|maxWidth|maxHeight|leading|trailing|top|bottom)?\s*:\s*\d+(?:\.\d+)?|\.(?:padding|frame|offset)\(\s*\d+(?:\.\d+)?|\.(?:padding|offset)\([^)]*,\s*\d+(?:\.\d+)?|(?:cornerRadius|cornerRadius:)\s*\(?\s*\d+(?:\.\d+)?|RoundedRectangle\(cornerRadius:\s*\d+(?:\.\d+)?")),
    ("shadow", re.compile(r"\.shadow\s*\(")),
    ("motion", re.compile(r"\.(?:easeIn|easeOut|easeInOut|linear)\(\s*duration\s*:\s*\d|\.spring\s*\(|\.animation\(\s*\.(?:ease|spring)")),
)

FEATURE_LOCAL_TOKEN = re.compile(
    r"(?:public|internal|private|fileprivate)?\s*static\s+(?:let|var)\s+\w+\s*:\s*(?:Color|Font|CGFloat|Double)\s*="
)


@dataclass(frozen=True)
class Finding:
    severity: str
    check: str
    message: str
    evidence: tuple[str, ...] = ()


class Audit:
    def __init__(self, root: Path) -> None:
        self.root = root
        self.findings: list[Finding] = []
        self._seen: set[tuple[str, str, str, tuple[str, ...]]] = set()

    def rel(self, path: Path) -> str:
        try:
            return path.resolve().relative_to(self.root).as_posix()
        except ValueError:
            return str(path)

    def add(
        self,
        severity: str,
        check: str,
        message: str,
        evidence: Iterable[str | Path] = (),
    ) -> None:
        normalized = tuple(str(item) for item in evidence)
        key = (severity, check, message, normalized)
        if key in self._seen:
            return
        self._seen.add(key)
        self.findings.append(Finding(severity, check, message, normalized))

    def pass_check(self, check: str, message: str, evidence: Iterable[str | Path] = ()) -> None:
        self.add("pass", check, message, evidence)

    def read(self, relative: str) -> str:
        path = self.root / relative
        try:
            return path.read_text(encoding="utf-8")
        except (OSError, UnicodeError):
            return ""


def resolve_link(base: Path, link: str) -> Path:
    link = link.split("#", 1)[0].strip().strip("<>")
    return (base / link).resolve()


def png_dimensions(path: Path) -> tuple[int, int] | None:
    try:
        data = path.read_bytes()
    except OSError:
        return None
    if len(data) < 24 or data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        return None
    width, height = struct.unpack(">II", data[16:24])
    return (width, height) if width and height else None


def valid_svg(path: Path) -> bool:
    try:
        root = ET.parse(path).getroot()
    except (OSError, ET.ParseError):
        return False
    return root.tag.rsplit("}", 1)[-1] == "svg"


def catalog_rows(text: str) -> list[tuple[str, str, str]]:
    row = re.compile(
        r"^\|\s*`([^`]+)`\s*\|.*?\|\s*\[[^\]]+\]\(([^)]+\.md)\)\s*\|\s*\[[^\]]+\]\(([^)]+\.png)\)\s*\|$"
    )
    return [match.groups() for line in text.splitlines() if (match := row.match(line))]


def check_required_files(audit: Audit) -> None:
    missing = [relative for relative in REQUIRED_FILES if not (audit.root / relative).is_file()]
    if missing:
        audit.add("blocker", "authority", "Required contract files are missing.", missing)
    else:
        audit.pass_check("authority", "All required Ripple authority and handoff documents exist.", REQUIRED_FILES)


def check_design_contract(audit: Audit) -> None:
    path = audit.root / "Docs/shared/Ripple_DESIGN_SYSTEM.md"
    text = path.read_text(encoding="utf-8") if path.is_file() else ""
    missing = [term for term in DESIGN_SYSTEM_TERMS if term not in text]
    if missing:
        audit.add("blocker", "design-system-contract", "The design-system contract is missing required token/native-control language.", missing)
    else:
        audit.pass_check("design-system-contract", "Named token families, native-control policy, and Reduce Motion are documented.", [audit.rel(path)])


def check_surfaces(audit: Audit) -> set[str]:
    catalog_path = audit.root / "Docs/shared/Ripple_SCREEN_CATALOG.md"
    catalog = catalog_path.read_text(encoding="utf-8") if catalog_path.is_file() else ""
    rows = catalog_rows(catalog)
    ids = [row[0] for row in rows]
    id_set = set(ids)

    if len(rows) != EXPECTED_SURFACE_COUNT:
        audit.add("blocker", "surface-index", f"Expected {EXPECTED_SURFACE_COUNT} catalog rows, found {len(rows)}.", [audit.rel(catalog_path)])
    else:
        audit.pass_check("surface-index", f"The catalog contains {EXPECTED_SURFACE_COUNT} parseable stable-surface rows.", [audit.rel(catalog_path)])
    if len(id_set) != len(ids):
        audit.add("blocker", "surface-index", "The surface catalog contains duplicate stable IDs.", [audit.rel(catalog_path)])

    screen_dir = audit.root / "Docs/shared/screens"
    actual_docs = {path.stem for path in screen_dir.glob("*.md")} if screen_dir.is_dir() else set()
    missing_docs = sorted(id_set - actual_docs)
    extra_docs = sorted(actual_docs - id_set)
    if missing_docs:
        audit.add("blocker", "surface-index", "Stable IDs without canonical screen files.", missing_docs)
    if extra_docs:
        audit.add("warning", "surface-index", "Screen Markdown files are not indexed by a stable ID.", extra_docs)
    if not missing_docs and not extra_docs:
        audit.pass_check("surface-index", "Every indexed stable ID maps to one canonical screen file.", [audit.rel(screen_dir)])

    inventory_path = audit.root / "Docs/shared/Ripple_VISUAL_REFERENCE_INVENTORY.md"
    inventory = inventory_path.read_text(encoding="utf-8") if inventory_path.is_file() else ""
    missing_inventory = [surface_id for surface_id in ids if not re.search(rf"^##\s+{re.escape(surface_id)}\s*$", inventory, re.MULTILINE)]
    if missing_inventory:
        audit.add("blocker", "visual-inventory", "Stable surfaces without an inventory section.", missing_inventory)
    else:
        audit.pass_check("visual-inventory", "Every stable surface has a visual-reference inventory section.", [audit.rel(inventory_path)])

    for surface_id, description_link, png_link in rows:
        description_path = resolve_link(catalog_path.parent, description_link)
        png_path = resolve_link(catalog_path.parent, png_link)
        if not description_path.is_file():
            audit.add("blocker", "surface-contract", "Canonical surface description is missing.", [surface_id, description_link])
            continue
        if not png_path.is_file():
            audit.add("blocker", "wireframe-assets", "Primary wireframe PNG is missing.", [surface_id, png_link])

        text = description_path.read_text(encoding="utf-8", errors="replace")
        for section in REQUIRED_SURFACE_SECTIONS:
            if f"## {section}" not in text:
                audit.add("blocker", "surface-contract", f"Canonical surface is missing the required section: {section}.", [audit.rel(description_path)])
        version_match = re.search(r"^\*\*Surface contract version:\*\*\s*(\S+)", text, re.MULTILINE)
        verified_match = re.search(r"^\*\*Last verified:\*\*\s*(\S+)", text, re.MULTILINE)
        if not version_match or not verified_match:
            audit.add("blocker", "surface-contract", "Canonical surface lacks version or Last verified metadata.", [audit.rel(description_path)])
        elif version_match.group(1) not in text[text.find("## Timeline") :]:
            audit.add("blocker", "surface-contract", "Canonical surface version is not recorded in its immutable timeline.", [audit.rel(description_path), version_match.group(1)])

        if f"Ripple_VISUAL_REFERENCE_INVENTORY.md#{surface_id}" not in text:
            audit.add("blocker", "visual-inventory", "Canonical surface does not link its visible-element inventory anchor.", [audit.rel(description_path)])

        forbidden = [term for term in FORBIDDEN_CANONICAL_TERMS if term in text]
        if forbidden:
            audit.add("blocker", "platform-neutrality", "Canonical surface contains platform/framework instructions.", [audit.rel(description_path), *forbidden])

        source_match = re.search(r"Editable source:\s*\[[^\]]+\]\(([^)]+\.svg)\)", text)
        if not source_match:
            audit.add("blocker", "wireframe-assets", "Canonical surface has no editable SVG source link.", [audit.rel(description_path)])
        else:
            svg_path = resolve_link(description_path.parent, source_match.group(1))
            if not svg_path.is_file():
                audit.add("blocker", "wireframe-assets", "Editable SVG source is missing.", [surface_id, source_match.group(1)])
            elif png_path.is_file() and svg_path.stem != png_path.stem:
                audit.add("blocker", "wireframe-assets", "PNG and editable SVG do not have the same stem.", [audit.rel(png_path), audit.rel(svg_path)])

        if png_path.is_file() and not png_dimensions(png_path):
            audit.add("blocker", "wireframe-assets", "Primary wireframe is not a decodable PNG with dimensions.", [audit.rel(png_path)])
        if source_match:
            svg_path = resolve_link(description_path.parent, source_match.group(1))
            if svg_path.is_file() and not valid_svg(svg_path):
                audit.add("blocker", "wireframe-assets", "Editable wireframe source is not valid SVG/XML.", [audit.rel(svg_path)])

    if not audit.findings or not any(f.severity == "blocker" and f.check in {"surface-index", "surface-contract", "wireframe-assets", "visual-inventory", "platform-neutrality"} for f in audit.findings):
        audit.pass_check("surface-coverage", "Indexed canonical surfaces expose the required contract, inventory, and editable-asset checks.", [audit.rel(catalog_path)])
    return id_set


def source_severity(path: Path, root: Path) -> str:
    relative = path.resolve().relative_to(root).as_posix()
    if relative.startswith("Packages/RippleFeatures/") or relative.startswith("Packages/RippleUI/Sources/RippleUI/") or relative.startswith("Extensions/"):
        return "blocker"
    return "warning"


def token_file_is_allowed(path: Path, root: Path, category: str) -> bool:
    relative = path.resolve().relative_to(root).as_posix()
    if "/Tokens/" in relative:
        return True
    if relative.endswith("/Motion/RippleMotion.swift"):
        return True
    if category == "layout" and "/Hero/" in relative:
        return True
    return False


def check_swift_tokens(audit: Audit) -> None:
    roots = (
        audit.root / "Apps",
        audit.root / "Extensions",
        audit.root / "Packages/RippleFeatures/Sources",
        audit.root / "Packages/RippleUI/Sources",
    )
    files: list[Path] = []
    for source_root in roots:
        if source_root.is_dir():
            files.extend(source_root.rglob("*.swift"))
    findings = 0
    scanned = 0
    for path in sorted(set(files)):
        scanned += 1
        text = path.read_text(encoding="utf-8", errors="replace")
        for line_number, line in enumerate(text.splitlines(), start=1):
            if "readiness: allow-token-audit" in line:
                continue
            if FEATURE_LOCAL_TOKEN.search(line) and not token_file_is_allowed(path, audit.root, "layout"):
                severity = source_severity(path, audit.root)
                audit.add(severity, "design-token-usage", "Production Swift declares a feature-local visual token/value.", [f"{audit.rel(path)}:{line_number}", line.strip()])
                findings += 1
            for category, pattern in STYLE_PATTERNS:
                if not pattern.search(line) or token_file_is_allowed(path, audit.root, category):
                    continue
                severity = source_severity(path, audit.root)
                audit.add(severity, "design-token-usage", f"Raw {category} styling should use RippleUI tokens or an explicitly documented adapter.", [f"{audit.rel(path)}:{line_number}", line.strip()])
                findings += 1
    if findings == 0:
        audit.pass_check("design-token-usage", f"No raw production Swift token violations found across {scanned} files.", ["Apps", "Extensions", "Packages/RippleFeatures/Sources", "Packages/RippleUI/Sources"])
    else:
        audit.add("warning", "design-token-usage", f"Review {findings} raw-style finding(s); blockers above apply to feature/components/extensions.", ["skills/android-conversion-readiness/references/readiness-checklist.md"])


def check_android_mapping(audit: Audit, surface_ids: set[str]) -> None:
    ui_spec_path = audit.root / "Docs/shared/Android/ANDROID_UI_SPEC.md"
    architecture_path = audit.root / "Docs/shared/Android/ANDROID_ARCHITECTURE.md"
    pack_path = audit.root / "Docs/shared/Android/UI/README.md"
    text = "\n".join(path.read_text(encoding="utf-8", errors="replace") for path in (ui_spec_path, architecture_path, pack_path) if path.is_file())
    missing_ids = [surface_id for surface_id in sorted(surface_ids) if not re.search(rf"`{re.escape(surface_id)}`", text)]
    if missing_ids:
        audit.add("blocker", "android-mapping", "Stable IDs are not mentioned in the Android handoff documents.", missing_ids)
    else:
        audit.pass_check("android-mapping", "Every stable ID is represented in the Android architecture/UI/reference handoff.", [audit.rel(ui_spec_path), audit.rel(architecture_path), audit.rel(pack_path)])
    missing_terms = [term for term in ANDROID_ACCEPTANCE_TERMS if term.lower() not in text.lower()]
    if missing_terms:
        audit.add("blocker", "android-acceptance", "Android handoff is missing required acceptance language.", missing_terms)
    else:
        audit.pass_check("android-acceptance", "Android handoff includes native, accessibility, reduced-motion, wearable, and surface-completion acceptance language.", [audit.rel(ui_spec_path)])

    android_project_roots = [audit.root / "Android", audit.root / "android"]
    implementation_files = [path for candidate in android_project_roots if candidate.is_dir() for path in candidate.rglob("*.kt")]
    if implementation_files:
        audit.pass_check("android-project", "An Android implementation repository is present locally; implementation-level checks can be run next.", [audit.rel(implementation_files[0].parent)])
    else:
        audit.add("warning", "android-project", "No local Android implementation repository was found; runtime/build acceptance is deferred to the independent Android project.", ["Android/", "android/"])


def check_boundaries(audit: Audit) -> None:
    domain_use_case_dir = audit.root / "Packages/RippleDomain/Sources/RippleDomain/UseCases"
    log_intake = domain_use_case_dir / "LogIntake.swift"
    declarations = list((audit.root / "Packages").rglob("*.swift")) if (audit.root / "Packages").is_dir() else []
    declaration_hits = 0
    for path in declarations:
        text = path.read_text(encoding="utf-8", errors="replace")
        declaration_hits += len(re.findall(r"\b(?:struct|class|enum)\s+LogIntake\b", text))
    if not log_intake.is_file() or declaration_hits != 1:
        audit.add("blocker", "source-of-truth", "The repository does not expose exactly one domain LogIntake use-case declaration.", [audit.rel(log_intake), str(declaration_hits)])
    else:
        audit.pass_check("source-of-truth", "Exactly one LogIntake domain boundary is discoverable.", [audit.rel(log_intake)])

    architecture = audit.read("Docs/shared/Android/ANDROID_ARCHITECTURE.md")
    boundary_terms = ("Health Connect is a projection", "All platform entry points use the same use cases", "At least one test per use case")
    missing = [term for term in boundary_terms if term not in architecture]
    if missing:
        audit.add("blocker", "source-of-truth", "Android architecture does not state all required source-of-truth/test boundaries.", missing)
    else:
        audit.pass_check("source-of-truth", "Android architecture states unified use-case, projection, and use-case-test boundaries.", ["Docs/shared/Android/ANDROID_ARCHITECTURE.md"])

    test_files = list((audit.root / "Packages").rglob("*Tests/*.swift")) if (audit.root / "Packages").is_dir() else []
    if not test_files:
        audit.add("blocker", "tests", "No package test sources were found for domain/data prerequisite verification.", ["Packages/**/Tests"])
    else:
        audit.pass_check("tests", f"Found {len(test_files)} package test source file(s); inspect use-case-specific coverage before implementation.", [audit.rel(path) for path in test_files[:8]])


def result_status(findings: list[Finding]) -> str:
    if any(f.severity == "blocker" for f in findings):
        return "BLOCKED"
    if any(f.severity == "warning" for f in findings):
        return "READY WITH WARNINGS"
    return "READY"


def print_text(audit: Audit, status: str) -> None:
    print(f"Android conversion readiness: {status}")
    print(f"Repository: {audit.root}")
    print()
    for severity, label in (("blocker", "BLOCKERS"), ("warning", "WARNINGS / DEFERRED"), ("pass", "PASSED")):
        items = [finding for finding in audit.findings if finding.severity == severity]
        if not items:
            continue
        print(f"{label} ({len(items)}):")
        for finding in items:
            evidence = "; ".join(finding.evidence)
            suffix = f" [{evidence}]" if evidence else ""
            print(f"- {finding.check}: {finding.message}{suffix}")
        print()
    counts = {severity: sum(f.severity == severity for f in audit.findings) for severity in ("blocker", "warning", "pass")}
    print(f"Summary: {counts['blocker']} blocker(s), {counts['warning']} warning(s), {counts['pass']} passed check(s).")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("root", nargs="?", default=".", help="Repository root to audit (default: current directory).")
    parser.add_argument("--format", choices=("text", "json"), default="text")
    parser.add_argument("--strict", action="store_true", help="Return failure for warnings as well as blockers.")
    args = parser.parse_args()

    root = Path(args.root).expanduser().resolve()
    if not root.is_dir():
        print(f"Not a directory: {root}", file=sys.stderr)
        return 2

    audit = Audit(root)
    check_required_files(audit)
    check_design_contract(audit)
    surface_ids = check_surfaces(audit)
    check_swift_tokens(audit)
    check_android_mapping(audit, surface_ids)
    check_boundaries(audit)
    status = result_status(audit.findings)

    if args.format == "json":
        counts = {severity: sum(f.severity == severity for f in audit.findings) for severity in ("blocker", "warning", "pass")}
        print(json.dumps({"status": status, "repository": str(root), "counts": counts, "findings": [asdict(finding) for finding in audit.findings]}, indent=2))
    else:
        print_text(audit, status)

    if any(f.severity == "blocker" for f in audit.findings):
        return 1
    if args.strict and any(f.severity == "warning" for f in audit.findings):
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

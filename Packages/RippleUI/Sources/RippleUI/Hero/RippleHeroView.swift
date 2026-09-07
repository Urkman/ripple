import Foundation
import SwiftUI

public struct RippleHeroView: View {
    public var consumedMl: Int
    public var goalMl: Int
    public var addedMl: Int?
    public var phase: RippleMotionPhase
    public var reduceMotion: Bool
    public var animatesPour: Bool
    public var showsPour: Bool
    public var expandsToFit: Bool
    public var slosh: CGFloat
    public var tilt: CGFloat
    public var amountText: String
    public var unitText: String
    public var percentText: String
    public var accessibilitySummary: String

    @State private var visualLevel: CGFloat
    @State private var pourDepth: CGFloat = 0
    @State private var ripplePosition: CGFloat = 0
    @State private var rippleAmplitude: CGFloat = 0
    @State private var displayedAmountText: String
    @State private var displayedPercentText: String
    @State private var numberEpoch = 0
    @State private var glassSize = CGSize(
        width: RippleMotion.heroWidth,
        height: RippleMotion.heroHeight
    )
    @State private var streamProgress: CGFloat = 0
    @State private var streamOpacity: Double = 0
    @State private var streamWidthScale: CGFloat = 1
    @State private var streamVisible = false
    @State private var pourProgress: CGFloat = 0
    @State private var pourStartLevel: CGFloat = 0
    @State private var pourTargetLevel: CGFloat = 0
    @State private var pourActiveDuration: TimeInterval = 0
    @State private var pourTotalDuration: TimeInterval = 0
    @State private var pourClockActive = false
    @State private var isAddPlaying = false
    @State private var hasContact = false
    @State private var leadInTask: Task<Void, Never>?
    @State private var pourEndTask: Task<Void, Never>?
    @State private var rippleTask: Task<Void, Never>?
    @State private var pourClockTask: Task<Void, Never>?

    public init(
        consumedMl: Int,
        goalMl: Int,
        addedMl: Int? = nil,
        phase: RippleMotionPhase = .idle,
        reduceMotion: Bool,
        animatesPour: Bool = true,
        showsPour: Bool = true,
        expandsToFit: Bool = false,
        tilt: CGFloat = 0,
        slosh: CGFloat = 0,
        amountText: String,
        unitText: String,
        percentText: String,
        accessibilitySummary: String
    ) {
        self.consumedMl = consumedMl
        self.goalMl = goalMl
        self.addedMl = addedMl
        self.phase = phase
        self.reduceMotion = reduceMotion
        self.animatesPour = animatesPour
        self.showsPour = showsPour
        self.expandsToFit = expandsToFit
        self.tilt = tilt
        self.slosh = slosh
        self.amountText = amountText
        self.unitText = unitText
        self.percentText = percentText
        self.accessibilitySummary = accessibilitySummary
        let level = RippleMotion.fillLevel(consumedMl: consumedMl, goalMl: goalMl)
        _visualLevel = State(initialValue: level)
        _displayedAmountText = State(initialValue: amountText)
        _displayedPercentText = State(initialValue: percentText)
    }

    public var body: some View {
        Group {
            if expandsToFit {
                artwork
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .aspectRatio(RippleMotion.heroWidth / RippleMotion.heroHeight, contentMode: .fit)
            } else {
                artwork
                    .aspectRatio(RippleMotion.heroWidth / RippleMotion.heroHeight, contentMode: .fit)
                    .frame(maxWidth: RippleMotion.heroWidth, maxHeight: RippleMotion.heroHeight)
            }
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { size in
            glassSize = size
        }
        .padding(.top, RippleMotion.pourStartAboveGlass)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilitySummary)
        .onChange(of: consumedMl) { oldValue, newValue in
            handleConsumedChange(from: oldValue, to: newValue)
        }
        .onChange(of: phase) { _, newPhase in
            if newPhase.isUndo {
                cancelAddAndSettle(duration: RippleMotion.undoDuration)
            }
        }
        .onChange(of: reduceMotion) { _, isEnabled in
            if isEnabled {
                cancelAddAndSettle(duration: RippleMotion.reduceMotionCrossfade)
            }
        }
        .onDisappear {
            cancelAddAndSettle(duration: 0)
        }
    }

    private var artwork: some View {
        let metrics = GlassMetrics(in: CGRect(origin: .zero, size: glassSize))

        return ZStack {
            if showsPour, !reduceMotion, let addedMl, streamVisible {
                let height = streamHeight(in: metrics)
                PourStreamView(addedMl: addedMl, progress: streamProgress)
                    .frame(height: height)
                    .position(
                        x: metrics.centerX,
                        y: streamTopY(in: metrics) + height / 2
                    )
                    .scaleEffect(x: renderedStreamWidthScale, y: 1, anchor: .center)
                    .opacity(renderedStreamOpacity)
            }

            WaterFill(
                level: renderedLevel,
                tilt: reduceMotion ? 0 : tilt,
                slosh: reduceMotion ? 0 : slosh,
                pourDepth: reduceMotion || !animatesPour ? 0 : pourDepth,
                ripplePosition: ripplePosition,
                rippleAmplitude: reduceMotion || !animatesPour ? 0 : rippleAmplitude
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            GlassShape()
                .stroke(RippleColor.waterLagoon, lineWidth: GlassMetrics.strokeWidth)

            readout
        }
    }

    private var readout: some View {
        GlassReadout(
            amountText: displayedAmountText,
            unitText: unitText,
            percentText: displayedPercentText,
            numberEpoch: numberEpoch,
            reduceMotion: reduceMotion
        )
    }

    private func streamTopY(in metrics: GlassMetrics) -> CGFloat {
        metrics.rimTopY - RippleMotion.pourStartAboveGlass
    }

    private func streamHeight(in metrics: GlassMetrics) -> CGFloat {
        let surfaceMetrics = GlassMetrics(
            in: metrics.rect,
            inset: GlassMetrics.strokeWidth
        )
        let contactY = WaterSurfaceGeometry(
            metrics: surfaceMetrics, level: renderedLevel,
            tilt: reduceMotion ? 0 : tilt, slosh: reduceMotion ? 0 : slosh,
            pourDepth: pourDepth, ripplePosition: ripplePosition,
            rippleAmplitude: rippleAmplitude
        ).contactY(atX: surfaceMetrics.centerX, fallback: surfaceMetrics.bottomY)
        return max(contactY - streamTopY(in: metrics), 1)
    }

    private var renderedLevel: CGFloat {
        guard pourClockActive else { return visualLevel }
        return RippleMotion.pourLevel(
            start: pourStartLevel,
            target: pourTargetLevel,
            progress: pourProgress
        )
    }

    private var renderedStreamOpacity: Double {
        guard pourClockActive else { return streamOpacity }
        let fadeProgress = RippleMotion.pourFadeProgress(
            progress: pourProgress,
            activeDuration: pourActiveDuration,
            totalDuration: pourTotalDuration
        )
        return streamOpacity * Double(1 - fadeProgress)
    }

    private var renderedStreamWidthScale: CGFloat {
        guard pourClockActive else { return streamWidthScale }
        let fadeProgress = RippleMotion.pourFadeProgress(
            progress: pourProgress,
            activeDuration: pourActiveDuration,
            totalDuration: pourTotalDuration
        )
        let fadeScale = RippleMotion.pourExitScale
            + (1 - RippleMotion.pourExitScale) * (1 - fadeProgress)
        return streamWidthScale * fadeScale
    }

    private func handleConsumedChange(from oldValue: Int, to newValue: Int) {
        if reduceMotion {
            cancelAnimationTasks()
            commitNumbers(roll: false)
            withAnimation(.easeInOut(duration: RippleMotion.reduceMotionCrossfade)) {
                visualLevel = RippleMotion.fillLevel(consumedMl: newValue, goalMl: goalMl)
                pourDepth = 0
                rippleAmplitude = 0
            }
            return
        }

        if !animatesPour {
            commitNumbers(roll: false)
            var update = Transaction()
            update.disablesAnimations = true
            withTransaction(update) {
                visualLevel = RippleMotion.fillLevel(consumedMl: newValue, goalMl: goalMl)
            }
            return
        }

        if newValue < oldValue || phase.isUndo {
            cancelAddAndSettle(duration: RippleMotion.undoDuration)
            return
        }

        guard newValue > oldValue else { return }

        guard addedMl != nil else {
            commitNumbers(roll: false)
            withAnimation(RippleMotion.springLiquid) {
                visualLevel = RippleMotion.fillLevel(consumedMl: newValue, goalMl: goalMl)
            }
            return
        }

        if isAddPlaying {
            continueActivePour(deltaMl: newValue - oldValue)
        } else {
            playPour()
        }
    }

    private func playPour() {
        cancelAnimationTasks()
        isAddPlaying = true
        hasContact = false

        var placement = Transaction()
        placement.disablesAnimations = true
        withTransaction(placement) {
            streamProgress = 0
            streamOpacity = 0
            streamWidthScale = 0.82
            streamVisible = true
            pourDepth = 0
            ripplePosition = RippleMotion.rippleStartPosition
            rippleAmplitude = 0
        }

        withAnimation(.easeOut(duration: RippleMotion.pourLeadIn)) {
            streamProgress = 1
            streamOpacity = 1
            streamWidthScale = 1
        }

        leadInTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(RippleMotion.pourLeadIn))
            guard !Task.isCancelled else { return }
            leadInTask = nil
            beginOrExtendPour(deltaMl: addedMl ?? 0)
        }
    }

    private func continueActivePour(deltaMl: Int) {
        if rippleTask != nil {
            restartPourAfterRipple(deltaMl: deltaMl)
            return
        }

        guard hasContact else {
            return
        }
        beginOrExtendPour(deltaMl: deltaMl)
    }

    private func restartPourAfterRipple(deltaMl: Int) {
        rippleTask?.cancel()
        rippleTask = nil

        var placement = Transaction()
        placement.disablesAnimations = true
        withTransaction(placement) {
            streamProgress = 1
            streamOpacity = 0
            streamWidthScale = RippleMotion.pourExitScale
            streamVisible = true
            ripplePosition = RippleMotion.rippleStartPosition
            rippleAmplitude = 0
        }
        withAnimation(.easeOut(duration: RippleMotion.pourLeadIn)) {
            streamOpacity = 1
            streamWidthScale = 1
        }
        beginOrExtendPour(deltaMl: deltaMl)
    }

    private func beginOrExtendPour(deltaMl: Int) {
        hasContact = true
        commitNumbers(roll: true)

        let seriesAmount = max(addedMl ?? deltaMl, deltaMl)
        let targetLevel = RippleMotion.fillLevel(
            consumedMl: consumedMl,
            goalMl: goalMl
        )
        let currentLevel = renderedLevel
        let activeDuration = RippleMotion.pourDuration(for: seriesAmount)
        let totalDuration = RippleMotion.levelRiseDuration(for: seriesAmount)
        var clockReset = Transaction()
        clockReset.disablesAnimations = true
        withTransaction(clockReset) {
            pourStartLevel = currentLevel
            pourTargetLevel = targetLevel
            pourActiveDuration = activeDuration
            pourTotalDuration = totalDuration
            pourProgress = 0
            pourClockActive = true
        }
        startPourClock(duration: totalDuration)
        withAnimation(.smooth(duration: RippleMotion.pourDepthFadeOut)) {
            pourDepth = RippleMotion.pourDepth(for: seriesAmount)
            rippleAmplitude = 0
        }
        schedulePourEnd(after: activeDuration)
    }

    private func startPourClock(duration: TimeInterval) {
        pourClockTask?.cancel()
        let startDate = Date()
        pourClockTask = Task { @MainActor in
            while !Task.isCancelled {
                let elapsed = Date().timeIntervalSince(startDate)
                let progress = RippleMotion.pourProgress(
                    elapsed: elapsed,
                    duration: duration
                )
                var update = Transaction()
                update.disablesAnimations = true
                withTransaction(update) {
                    pourProgress = progress
                }
                if progress >= 1 { break }
                try? await Task.sleep(
                    for: .seconds(RippleMotion.pourClockStep)
                )
            }

            guard !Task.isCancelled else { return }
            var completion = Transaction()
            completion.disablesAnimations = true
            withTransaction(completion) {
                pourProgress = 1
                visualLevel = pourTargetLevel
            }
            pourClockTask = nil
        }
    }

    private func schedulePourEnd(after duration: TimeInterval) {
        pourEndTask?.cancel()
        pourEndTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            pourEndTask = nil
            finishPour()
        }
    }

    private func finishPour() {
        hasContact = false
        let amount = addedMl ?? 0
        let outboundAmplitude = RippleMotion.rippleAmplitude(for: amount)

        withAnimation(.easeOut(duration: RippleMotion.pourDepthFadeOut)) {
            pourDepth = 0
        }
        withAnimation(.easeOut(duration: RippleMotion.rippleOutboundDuration)) {
            ripplePosition = RippleMotion.rippleOutboundPosition
            rippleAmplitude = outboundAmplitude
        }

        rippleTask?.cancel()
        rippleTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(RippleMotion.rippleOutboundDuration))
            guard !Task.isCancelled else { return }
            withAnimation(.smooth(duration: RippleMotion.rippleTurnDuration)) {
                rippleAmplitude = -outboundAmplitude * RippleMotion.rippleReflectionRatio
            }

            try? await Task.sleep(for: .seconds(RippleMotion.rippleTurnDuration))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: RippleMotion.rippleReturnDuration)) {
                ripplePosition = RippleMotion.rippleReflectionPosition
                rippleAmplitude = -outboundAmplitude
                    * RippleMotion.rippleReflectionRatio
                    * RippleMotion.rippleReturnDecay
            }

            try? await Task.sleep(for: .seconds(RippleMotion.rippleReturnDuration))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: RippleMotion.rippleSettleDuration)) {
                ripplePosition = RippleMotion.rippleSettlePosition
                rippleAmplitude = 0
            }

            try? await Task.sleep(for: .seconds(RippleMotion.rippleSettleDuration))
            guard !Task.isCancelled else { return }
            var reset = Transaction()
            reset.disablesAnimations = true
            withTransaction(reset) {
                streamVisible = false
                streamOpacity = 0
                streamWidthScale = RippleMotion.pourExitScale
                pourProgress = 0
                pourClockActive = false
            }
            isAddPlaying = false
            rippleTask = nil
        }
    }

    private func cancelAddAndSettle(duration: TimeInterval) {
        cancelAnimationTasks()
        isAddPlaying = false
        hasContact = false

        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            streamVisible = false
            streamProgress = 0
            streamOpacity = 0
            streamWidthScale = 1
            pourDepth = 0
            ripplePosition = 0
            rippleAmplitude = 0
        }
        commitNumbers(roll: false)
        withAnimation(.easeInOut(duration: duration)) {
            visualLevel = RippleMotion.fillLevel(consumedMl: consumedMl, goalMl: goalMl)
        }
    }

    private func cancelAnimationTasks() {
        leadInTask?.cancel()
        pourEndTask?.cancel()
        rippleTask?.cancel()
        pourClockTask?.cancel()
        leadInTask = nil
        pourEndTask = nil
        rippleTask = nil
        pourClockTask = nil
        var reset = Transaction()
        reset.disablesAnimations = true
        withTransaction(reset) {
            pourProgress = 0
            pourClockActive = false
        }
    }

    private func commitNumbers(roll: Bool) {
        if roll {
            withAnimation(RippleMotion.springLiquid) {
                displayedAmountText = amountText
                displayedPercentText = percentText
            }
        } else {
            numberEpoch += 1
            var transaction = Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                displayedAmountText = amountText
                displayedPercentText = percentText
            }
        }
    }
}

#Preview("Hero idle") {
    RippleHeroView(
        consumedMl: 1250,
        goalMl: 2000,
        phase: .idle,
        reduceMotion: false,
        amountText: "1\u{202F}250",
        unitText: "ml",
        percentText: "62\u{00A0}%",
        accessibilitySummary: "1 250 milliliters of 2 000. 62 percent. 750 milliliters left."
    )
    .padding()
    .background(RippleColor.waterFoam)
}

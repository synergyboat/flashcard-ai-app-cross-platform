//
//  BenchmarkViewController.swift
//  FlashcardAI
//

import UIKit
import QuartzCore

// MARK: - Config

private let ROW_HEIGHT: CGFloat = 80
private let DEFAULT_ITEMS = 100
private let DEFAULT_ITERATIONS = 3

enum BenchmarkTypeIOS: String, CaseIterable {
    case staticRender = "Static Render"
    case scrollPerformance = "Scroll Performance"
    case memoryUsage = "Memory Usage"
}

// MARK: - Platform Info

struct PlatformInfo {
    static let platformName = "iOS"
    static let performanceProfile = "iOS (Metal rendering, ARC memory)"
    static var actualRefreshRate: Double {
        if #available(iOS 10.3, *) { return Double(UIScreen.main.maximumFramesPerSecond) }
        return 60.0
    }
    static var targetFrameTimeMs: Double { 1000.0 / actualRefreshRate }
}

// MARK: - VC

final class BenchmarkViewController: UIViewController {

    // Public config
    var itemCount: Int = DEFAULT_ITEMS
    var iterations: Int = DEFAULT_ITERATIONS
    var benchmarkType: BenchmarkTypeIOS = .scrollPerformance

    // UI
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let statusLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .bar)
    private let configLabel = UILabel()

    // State
    private var currentIteration = 0
    private var results: [BenchmarkResult] = []
    private var benchmarkComplete = false

    // Frame capture
    private var displayLink: CADisplayLink?
    private var frameStartTime: CFTimeInterval = 0
    private var frameTimings: [Double] = []
    private var isCapturingFrames = false

    // Memory
    private var baselineRSSMB: Double = 0

    // Down-scroll window
    private var isScrollMeasuring = false
    private var scrollStartTime: CFTimeInterval = 0
    private var scrollEndTime: CFTimeInterval = 0
    private var scrollDistance: CGFloat = 0

    // Custom scroll driver
    private var scrollDriver: CADisplayLink?
    private var scrollTargetY: CGFloat = 0
    private var scrollStartY: CGFloat = 0
    private var scrollPxPerSec: CGFloat = 500.0
    private var scrollDriverStartTs: CFTimeInterval = 0

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Scientific List Benchmark"
        view.backgroundColor = .systemBackground
        setupUI()
        setupTableView()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
            guard let self = self else { return }
            self.recordBaselineMemory()
            self.runBenchmark()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopFrameMonitoring()
        stopScrollDriver()
        tableView.layer.removeAllAnimations()
    }

    // MARK: UI

    private func setupUI() {
        statusLabel.textAlignment = .center
        statusLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        statusLabel.textColor = .label
        statusLabel.numberOfLines = 0

        configLabel.textAlignment = .center
        configLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        configLabel.textColor = .secondaryLabel
        configLabel.numberOfLines = 0

        progressView.progressTintColor = .systemGreen
        progressView.trackTintColor = UIColor.label.withAlphaComponent(0.1)

        let header = UIStackView(arrangedSubviews: [statusLabel, configLabel, progressView])
        header.axis = .vertical
        header.spacing = 8
        header.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(header)
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self

        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false

        tableView.rowHeight = ROW_HEIGHT
        tableView.estimatedRowHeight = 0
        tableView.estimatedSectionHeaderHeight = 0
        tableView.estimatedSectionFooterHeight = 0
        if #available(iOS 15.0, *) { tableView.sectionHeaderTopPadding = 0 }

        tableView.register(BenchmarkCell.self, forCellReuseIdentifier: "BenchmarkCell")
        tableView.backgroundColor = .systemBackground
        tableView.contentInsetAdjustmentBehavior = .never
    }

    // MARK: Iterations

    private func runBenchmark() {
        guard currentIteration < iterations else { completeBenchmark(); return }
        updateUI()

        hardResetTableViewToTop()

        startFrameMonitoring()

        let t0 = CACurrentMediaTime()
        DispatchQueue.main.async {
            let ttfp = (CACurrentMediaTime() - t0) * 1000.0

            switch self.benchmarkType {
            case .staticRender, .memoryUsage:
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.finishIteration(timeToFirstFrameMs: ttfp, scrollDurationMs: 0, scrollDistancePx: 0)
                }

            case .scrollPerformance:
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) {
                    self.performMeasuredScroll(timeToFirstFrameMs: ttfp)
                }
            }
        }
    }

    private func nextIteration() {
        currentIteration += 1
        hardResetTableViewToTop()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.50) {
            self.runBenchmark()
        }
    }

    private func completeBenchmark() {
        benchmarkComplete = true
        updateUI()
        generateScientificReport()
    }

    private func updateUI() {
        let progress = Float(currentIteration) / Float(max(1, iterations))
        progressView.setProgress(progress, animated: true)
        statusLabel.text = benchmarkComplete
            ? "✅ Benchmark Complete!"
            : "Running iteration \(currentIteration + 1) of \(iterations)..."
        configLabel.text = "\(itemCount) items • \(benchmarkType.rawValue) • Target: \(String(format: "%.1f", PlatformInfo.targetFrameTimeMs))ms"
        if benchmarkComplete {
            statusLabel.textColor = .systemGreen
            view.backgroundColor = UIColor.systemGreen.withAlphaComponent(0.05)
        }
    }

    // MARK: Hard reset (ensures start at top)

    private func hardResetTableViewToTop() {
        stopScrollDriver()
        tableView.layer.removeAllAnimations()

        UIView.performWithoutAnimation {
            tableView.contentInset = .zero
            tableView.scrollIndicatorInsets = .zero
            tableView.setContentOffset(.zero, animated: false)
            tableView.reloadData()
            tableView.layoutIfNeeded()
        }

        DispatchQueue.main.async {
            self.tableView.layer.removeAllAnimations()
            self.tableView.setContentOffset(.zero, animated: false)
            self.tableView.layoutIfNeeded()
        }
    }

    // MARK: Scroll performance (down-leg only) — custom CADisplayLink driver

    private func performMeasuredScroll(timeToFirstFrameMs: Double) {
        hardResetTableViewToTop()

        guard tableView.numberOfRows(inSection: 0) > 0 else {
            finishIteration(timeToFirstFrameMs: timeToFirstFrameMs, scrollDurationMs: 0, scrollDistancePx: 0)
            return
        }

        let contentHeight = tableView.contentSize.height
        let visibleHeight = tableView.bounds.height
        let maxOffset = max(0, contentHeight - visibleHeight)
        guard maxOffset > 0 else {
            finishIteration(timeToFirstFrameMs: timeToFirstFrameMs, scrollDurationMs: 0, scrollDistancePx: 0)
            return
        }

        scrollDistance = maxOffset
        startDownScroll(to: maxOffset, speed: scrollPxPerSec) { [weak self] actualMs in
            guard let self = self else { return }
            // Return to top (unmeasured)
            self.tableView.setContentOffset(.zero, animated: true)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.20) {
                self.finishIteration(
                    timeToFirstFrameMs: timeToFirstFrameMs,
                    scrollDurationMs: Int(actualMs),
                    scrollDistancePx: Double(maxOffset)
                )
            }
        }
    }

    private func startDownScroll(to targetY: CGFloat, speed pxPerSec: CGFloat, completion: @escaping (_ durationMs: Double) -> Void) {
        stopScrollDriver()

        scrollTargetY = targetY
        scrollStartY = tableView.contentOffset.y
        scrollPxPerSec = max(1, pxPerSec)

        // Measure only during down scroll
        frameTimings.removeAll()
        isScrollMeasuring = true
        scrollStartTime = CACurrentMediaTime()

        let link = CADisplayLink(target: self, selector: #selector(handleScrollTick))
        link.add(to: .main, forMode: .common)
        scrollDriver = link
        scrollDriverStartTs = CACurrentMediaTime()

        // Capture completion on stop
        scrollCompletion = { [weak self] in
            guard let self = self else { return }
            self.isScrollMeasuring = false
            self.scrollEndTime = CACurrentMediaTime()
            let ms = (self.scrollEndTime - self.scrollStartTime) * 1000.0
            completion(ms)
        }
    }

    private var scrollCompletion: (() -> Void)?

    @objc private func handleScrollTick(_ link: CADisplayLink) {
        let now = CACurrentMediaTime()
        let elapsed = now - scrollDriverStartTs
        let delta = scrollPxPerSec * CGFloat(elapsed)                   // pixels since start
        let next = min(scrollStartY + delta, scrollTargetY)

        // IMPORTANT: animate by setting the property directly (not setContentOffset(animated:))
        tableView.contentOffset = CGPoint(x: 0, y: next)

        if next >= scrollTargetY - 0.5 {
            stopScrollDriver()
            scrollCompletion?()
            scrollCompletion = nil
        }
    }

    private func stopScrollDriver() {
        scrollDriver?.invalidate()
        scrollDriver = nil
    }

    // MARK: Frame monitoring

    private func startFrameMonitoring() {
        stopFrameMonitoring()
        frameStartTime = 0
        isCapturingFrames = true
        let link = CADisplayLink(target: self, selector: #selector(frameCallback))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    private func stopFrameMonitoring() {
        displayLink?.invalidate()
        displayLink = nil
        isCapturingFrames = false
    }

    @objc private func frameCallback(link: CADisplayLink) {
        let now = link.timestamp
        let shouldCapture = isCapturingFrames && (benchmarkType != .scrollPerformance || isScrollMeasuring)
        if shouldCapture && frameStartTime > 0 {
            let ms = (now - frameStartTime) * 1000.0
            frameTimings.append(ms)
        }
        frameStartTime = now
    }

    // MARK: Results

    private func finishIteration(timeToFirstFrameMs: Double, scrollDurationMs: Int, scrollDistancePx: Double) {
        stopFrameMonitoring()
        stopScrollDriver()

        let currentMB = getCurrentRSSMB()
        let memoryDelta = max(0, currentMB - baselineRSSMB)

        let result = BenchmarkResult(
            timeToFirstFrameMs: timeToFirstFrameMs,
            frameTimesMs: frameTimings,
            memoryDeltaMB: memoryDelta,
            itemCount: itemCount,
            targetFrameTimeMs: PlatformInfo.targetFrameTimeMs,
            scrollDurationMs: scrollDurationMs,
            scrollDistancePx: scrollDistancePx,
            panelRefreshHz: PlatformInfo.actualRefreshRate,
            timestamp: Date()
        )
        results.append(result)
        nextIteration()
    }

    // MARK: Memory

    private func recordBaselineMemory() {
        baselineRSSMB = getCurrentRSSMB()
        print("📊 Baseline RSS: \(String(format: "%.2f", baselineRSSMB)) MB")
    }

    private func getCurrentRSSMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4
        let kr = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }
        let bytes = (kr == KERN_SUCCESS) ? info.resident_size : 0
        return Double(bytes) / (1024.0 * 1024.0)
    }

    // MARK: Report

    private func generateScientificReport() {
        guard !results.isEmpty else { return }

        let allFrames = results.flatMap { $0.frameTimesMs }
        let totalFrames = allFrames.count
        let meanFrame = mean(allFrames)
        let p95 = percentile(allFrames, 0.95)

        let budget = PlatformInfo.targetFrameTimeMs
        let droppedStrict = fractionOver(allFrames, threshold: budget) * 100
        let droppedJanky = fractionOver(allFrames, threshold: budget * 1.5) * 100

        let totalScrollMs = results.map { $0.scrollDurationMs }.reduce(0, +)
        let fpsUnclamped = totalScrollMs > 0
            ? (Double(totalFrames) / (Double(totalScrollMs) / 1000.0))
            : (meanFrame > 0 ? 1000.0 / meanFrame : 0)
        let fpsClamped = min(fpsUnclamped, PlatformInfo.actualRefreshRate)

        let ttfpList = results.map { $0.timeToFirstFrameMs }
        let memList = results.map { $0.memoryDeltaMB }
        let perIterMeans = results.map { $0.averageFrameMs }

        let grade: String = {
            if meanFrame <= budget { return "A (Excellent)" }
            if meanFrame <= budget * 1.5 { return "B (Good)" }
            if meanFrame <= budget * 2.0 { return "C (Fair)" }
            return "D (Poor)"
        }()

        let report = """
[Benchmark/INFO] 🔬 SCIENTIFIC BENCHMARK REPORT
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📅 Timestamp: \(Date())
🔧 Platform: \(PlatformInfo.platformName) (\(PlatformInfo.performanceProfile))
📊 Configuration: \(itemCount) items, \(iterations) iterations
🎯 Benchmark Type: \(benchmarkType.rawValue)
⚡ Target Frame Time: \(fmt(budget))ms (\(Int(PlatformInfo.actualRefreshRate)) FPS)

📈 FRAME PERFORMANCE (aggregate):
• Avg Frame Time: \(fmt(meanFrame)) ms
• P95 Frame Time: \(fmt(p95)) ms
• Actual FPS (unclamped): \(fmt(fpsUnclamped))
• Actual FPS (clamped):   \(fmt(fpsClamped))
• Panel Refresh: \(Int(PlatformInfo.actualRefreshRate)) Hz
• Dropped Frames (strict > budget): \(fmtPct(droppedStrict))%
• Janky Frames (> 1.5× budget): \(fmtPct(droppedJanky))%
• Performance Grade: \(grade)

⏱️ INITIAL RENDER (per-iteration):
• Time to First Frame: \(fmt(mean(ttfpList))) ± \(fmt(stddev(ttfpList))) ms

🧠 MEMORY IMPACT (basis: RSS):
• Memory Delta: \(fmt(mean(memList))) ± \(fmt(stddev(memList))) MB
• Memory per Item: \(fmt((mean(memList) / Double(max(1, itemCount))) * 1000)) KB/item

📊 RELIABILITY:
• Coefficient of Variation (Frame Time): \(fmt((stddev(perIterMeans) / max(1e-6, mean(perIterMeans))) * 100))%
• Total Frames Analyzed: \(totalFrames)
• Scroll Distance: \(fmt(results.first?.scrollDistancePx ?? 0)) px
• Avg Scroll Duration: \(fmt(mean(results.map { Double($0.scrollDurationMs) }))) ms
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
"""
        print(report)
        statusLabel.text = "✅ Benchmark Complete — check Xcode console for report"
    }

    // MARK: Math helpers

    private func mean(_ v: [Double]) -> Double { guard !v.isEmpty else { return 0 }; return v.reduce(0,+) / Double(v.count) }
    private func stddev(_ v: [Double]) -> Double { guard v.count > 1 else { return 0 }; let m = mean(v); return sqrt(v.reduce(0){$0 + pow($1 - m, 2)} / Double(v.count)) }
    private func percentile(_ v: [Double], _ p: Double) -> Double {
        guard !v.isEmpty else { return 0 }; let s = v.sorted(); let i = max(0, Int(ceil(Double(s.count) * p)) - 1); return s[i]
    }
    private func fractionOver(_ v: [Double], threshold: Double) -> Double {
        guard !v.isEmpty else { return 0 }; return Double(v.filter{$0 > threshold}.count) / Double(v.count)
    }
    private func fmt(_ x: Double) -> String { String(format: "%.2f", x) }
    private func fmtPct(_ x: Double) -> String { String(format: "%.3f", x) }
}

// MARK: - Result model

private struct BenchmarkResult {
    let timeToFirstFrameMs: Double
    let frameTimesMs: [Double]
    let memoryDeltaMB: Double
    let itemCount: Int
    let targetFrameTimeMs: Double
    let scrollDurationMs: Int
    let scrollDistancePx: Double
    let panelRefreshHz: Double
    let timestamp: Date

    var averageFrameMs: Double {
        guard !frameTimesMs.isEmpty else { return 0 }
        return frameTimesMs.reduce(0, +) / Double(frameTimesMs.count)
    }
}

// MARK: - TableView

extension BenchmarkViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { itemCount }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { ROW_HEIGHT }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { ROW_HEIGHT }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BenchmarkCell", for: indexPath) as! BenchmarkCell
        cell.configure(index: indexPath.row, iteration: min(currentIteration + 1, iterations), total: iterations)
        return cell
    }
}

// MARK: - Cell

private final class BenchmarkCell: UITableViewCell {
    private let containerView = UIView()
    private let avatarView = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let hStack = UIStackView()
    private let vStack = UIStackView()

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.backgroundColor = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier); setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        containerView.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.06)
        containerView.layer.cornerRadius = 8
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemBlue.withAlphaComponent(0.25).cgColor

        avatarView.layer.cornerRadius = 24

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = .label
        subtitleLabel.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        subtitleLabel.textColor = .secondaryLabel

        vStack.axis = .vertical
        vStack.spacing = 2
        vStack.addArrangedSubview(titleLabel)
        vStack.addArrangedSubview(subtitleLabel)

        hStack.axis = .horizontal
        hStack.alignment = .center
        hStack.spacing = 12
        hStack.addArrangedSubview(avatarView)
        hStack.addArrangedSubview(vStack)
        hStack.addArrangedSubview(UIView())

        containerView.translatesAutoresizingMaskIntoConstraints = false
        hStack.translatesAutoresizingMaskIntoConstraints = false
        avatarView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(containerView)
        containerView.addSubview(hStack)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            containerView.heightAnchor.constraint(greaterThanOrEqualToConstant: ROW_HEIGHT - 8),

            avatarView.widthAnchor.constraint(equalToConstant: 48),
            avatarView.heightAnchor.constraint(equalToConstant: 48),

            hStack.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            hStack.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            hStack.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
    }

    func configure(index: Int, iteration: Int, total: Int) {
        let r = CGFloat((index * 50) % 200 + 55) / 255.0
        let g = CGFloat((index * 80) % 200 + 55) / 255.0
        let b = CGFloat((index * 120) % 200 + 55) / 255.0
        avatarView.backgroundColor = UIColor(red: r, green: g, blue: b, alpha: 1.0)
        titleLabel.text = "Benchmark Item \(index)"
        subtitleLabel.text = "Iteration \(iteration)/\(total)"
    }
}

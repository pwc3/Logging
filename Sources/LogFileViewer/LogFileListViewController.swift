//
//  LogFileListViewController.swift
//  LogFileViewer
//
//  Copyright (c) 2020 Anodized Software, Inc.
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
//  DEALINGS IN THE SOFTWARE.
//

import UIKit

class LogFileListViewController: UITableViewController {
    
    private let logsDirectory: URL

    private var logFiles: [URL] = []

    private let reuseIdentifier = "cell"
    
    init(logsDirectory: URL) {
        self.logsDirectory = logsDirectory
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(LogFileCell.self, forCellReuseIdentifier: reuseIdentifier)
        title = "Log Files"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if isMovingToParent {
            reload()
        }
    }

    private var spinner: UIView?

    private func showSpinner(in parentView: UIView) {
        let overlay = UIView(frame: parentView.bounds)
        self.spinner = overlay

        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.backgroundColor = UIColor.clear

        let activityIndicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
            activityIndicator.color = .white
        } else {
            activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        }

        let margin = CGFloat(30)

        let background = UIView(frame: CGRect(x: 0, y: 0,
                                              width: activityIndicator.bounds.width + margin * 2,
                                              height: activityIndicator.bounds.height + margin * 2))
        background.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin,
                                       .flexibleTopMargin, .flexibleBottomMargin]
        background.backgroundColor = UIColor(white: 0, alpha: 0.75)
        background.layer.cornerRadius = 10

        background.addSubview(activityIndicator)
        activityIndicator.center = background.center

        background.center = overlay.center
        overlay.addSubview(background)

        parentView.addSubview(overlay)
        activityIndicator.startAnimating()
    }

    private func hideSpinner() {
        spinner?.removeFromSuperview()
        spinner = nil
    }

    private func reload() {
        navigationController.map { showSpinner(in: $0.view) }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let urls = self?.loadLogFileURLs() ?? []

            DispatchQueue.main.async {
                self?.hideSpinner()

                self?.logFiles = urls
                self?.tableView.reloadData()
            }
        }
    }

    private func loadLogFileURLs() -> [URL]? {
        do {
            let files = try FileManager.default.contentsOfDirectory(
                at: logsDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants])

            return try files.sorted(by: { (u1, u2) -> Bool in
                let d1 = try u1.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast
                let d2 = try u2.resourceValues(forKeys: [.creationDateKey]).creationDate ?? Date.distantPast

                return d2 < d1
            })
        }
        catch {
            NSLog("Error loading log file paths: \(error)")
            return nil
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logFiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? LogFileCell else {
            fatalError("Could not dequeue expected cell type")
        }

        cell.configure(for: logFiles[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = logFiles[indexPath.row]
        navigationController.map { showSpinner(in: $0.view) }

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = Result(catching: {
                try String(contentsOf: url)
            })

            DispatchQueue.main.async {
                self?.hideSpinner()
                self?.showLogFileContents(result, from: url)
            }
        }
    }

    private func showLogFileContents(_ result: Result<String, Error>, from url: URL) {
        switch result {
        case .success(let contents):
            let vc = LogFileViewController(contents: contents, source: url)
            navigationController?.pushViewController(vc, animated: true)

        case .failure(let error):
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default))

            present(alert, animated: true)
        }
    }
}

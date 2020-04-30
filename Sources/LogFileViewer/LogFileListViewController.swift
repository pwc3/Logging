//
//  LogFileListViewController.swift
//  LogViewer
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

import Logging
import RIUIKitExtensions
import UIKit

class LogFileListViewController<Context>: UITableViewController where Context: LogContext {
    
    private let logService: LogService<Context>

    private var logFilePaths: [String] = []

    private let reuseIdentifier = "cell"
    
    init(logService: LogService<Context>) {
        self.logService = logService
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

    private var activityIndicator: ActivityIndicator?

    private func showActivityIndicator() {
        activityIndicator = ActivityIndicator.add(to: navigationController?.view)
    }

    private func hideActivityIndicator() {
        activityIndicator?.removeFromSuperview()
        activityIndicator = nil
    }

    private func reload() {
        showActivityIndicator()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let paths = self?.logService.fileLogger?.logFileManager.sortedLogFilePaths

            DispatchQueue.main.async {
                self?.hideActivityIndicator()

                self?.logFilePaths = paths ?? []
                self?.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logFilePaths.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? LogFileCell else {
            fatalError("Could not dequeue expected cell type")
        }

        cell.configure(forPath: logFilePaths[indexPath.row])
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = logFilePaths[indexPath.row]
        showActivityIndicator()

        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            let result = Result(catching: {
                try String(contentsOfFile: path)
            })

            DispatchQueue.main.async {
                self?.hideActivityIndicator()
                self?.showLogFileContents(result, fromPath: path)
            }
        }
    }

    private func showLogFileContents(_ result: Result<String, Error>, fromPath path: String) {
        switch result {
        case .success(let contents):
            let vc = LogFileViewController(contents: contents, path: path)
            navigationController?.pushViewController(vc, animated: true)

        case .failure(let error):
            show(error)
        }
    }
}

//
//  ListViewController.swift
//  SwipeRead
//
//  Created by MasakiOkuno on 2018/02/22.
//  Copyright © 2018年 masaki okuno. All rights reserved.
//

import UIKit
import AlamofireImage

class FeedTableViewController: UITableViewController {
    
    var headerView: FeedTableViewHeader!
    let downloader = ImageDownloader()
    
    override func loadView() {
        // load xib file
        if let tableView = UINib(nibName: "FeedTableViewController", bundle: nil).instantiate(withOwner: self, options: nil).first as? UITableView {
            self.tableView = tableView
        }
        
        if let headerView = UINib(nibName: "FeedTableViewHeader", bundle: nil).instantiate(withOwner: self, options: nil).first as? FeedTableViewHeader {
            self.headerView = headerView
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initTableView()
        initHeaderView()
        RSSFeedModel.shared.loadRssFeed(tableView: self.tableView)
        
    }
    
    override func viewDidLayoutSubviews() {
        let title = RSSFeedModel.shared.feed?.title ?? "[no title]"
        headerView.title.text = title
        self.navigationItem.title = title
    }
    
    
    private func initTableView() {
        // Eliminate the line where there is no cell
        tableView.tableFooterView = UIView()
    }
    
    // Add header view
    private func initHeaderView() {
        let headerHight = self.view.frame.height * 0.15
        let headerWidth = self.view.frame.width
        tableView.contentInset.top = headerHight
        headerView.frame = CGRect(x: 0, y: -(self.view.safeAreaInsets.top + tableView.contentInset.top), width: headerWidth, height: headerHight)
        tableView.addSubview(headerView)
    }
    
}


// MARK: - Table View Data Source

extension FeedTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RSSFeedModel.shared.itemsCount()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UINib(nibName: "FeedTableViewCell", bundle: nil).instantiate(withOwner: self, options: nil).first as! FeedTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.gray
        cell.titleLabel.text = RSSFeedModel.shared.feed?.items?[indexPath.row].title ?? "[no title]"
        
        let urlString = RSSFeedModel.shared.feed?.items?[indexPath.row].enclosure?.attributes?.url ?? ""
        
        // cell image setting
        cell.configureCell(with: urlString, placeholderImage: UIImage(named: "placeholder")!)
        
        return cell
    }
}


// MARK: - Table View Delegate

extension FeedTableViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showFeedDetailWithIndex(indexPath.row)
    }
    
}


// MARK: - Navigation

extension FeedTableViewController {
    
    func showFeedDetailWithIndex(_ index: Int) {
        // navigation item setting
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: " Back", style: .plain, target: nil, action: nil)
        
        // next view controller
        let rvc: RootViewController = storyboard!.instantiateViewController(withIdentifier: "RootViewController") as! RootViewController
        rvc.initIndex = index
        rvc.navTitle = RSSFeedModel.shared.feed?.title ?? "[no title]"
        show(rvc, sender:nil)
    }
    
}


// MARK: - Fix header view when scrolling

extension FeedTableViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard headerView != nil else {
            return
        }
        if scrollView.contentOffset.y < -(self.view.safeAreaInsets.top + tableView.contentInset.top) {
            self.headerView.frame = CGRect(x: 0, y: scrollView.contentOffset.y + self.view.safeAreaInsets.top, width: self.view.frame.width, height: headerView.frame.height)
        } else {
            self.headerView.frame = CGRect(x: 0, y: -tableView.contentInset.top, width: self.view.frame.width, height: headerView.frame.height)
        }
    }
}


// MARK: - Load image view cell image

extension FeedTableViewController {
    func downloadImage(imageView: UIImageView, indexPath: IndexPath, url: URL) {
        let downloader = ImageDownloader()
        let urlRequest = URLRequest(url: url)
        
        downloader.download(urlRequest) { response in
            if let image = response.result.value {
                imageView.image = image
            }
        }
        
    }
}


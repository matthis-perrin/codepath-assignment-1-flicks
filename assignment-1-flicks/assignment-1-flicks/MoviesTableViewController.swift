//
//  MoviesViewController.swift
//  assignment-1-flicks
//
//  Created by Matthis Perrin on 2/6/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD

class MoviesTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var errorView: UIView!
    let refreshControl = UIRefreshControl()
    
    private var _data: NSDictionary!
    
    func getAPIURL() -> String {
        return ""
    }
    
    private func _loadMovieData(initialLoad: Bool) {
        // Create the API url
        let urlString = self.getAPIURL()
        guard let url = NSURL(string: urlString) else {
            print("Invalid URL \(urlString), check the `getAPIURL` method.")
            return
        }
        
        // Prepare the request
        let request = NSURLRequest(URL: url)
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        
        // Create the network task
        let task : NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                print(error)
                if initialLoad {
                    MBProgressHUD.hideHUDForView(self.view, animated: true)
                } else {
                    self.refreshControl.endRefreshing()
                }
                if let data = dataOrNil {
                    self.errorView.hidden = true
                    if let res = try! NSJSONSerialization.JSONObjectWithData(data, options:[]) as? NSDictionary {
                        self._data = res
                        self.tableView.reloadData()
                    }
                } else {
                    self.errorView.hidden = false
                }
        });
        
        // Show the progress HUD if it's the initial load
        if initialLoad {
            MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        }
        
        // Start fetching the data
        task.resume()
    }
    
    private func _getMovies() -> [NSDictionary] {
        guard let data = self._data else { return [] }
        guard let result = data["results"] as? [NSDictionary] else { return [] }
        return result
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        self._loadMovieData(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = 155
        self.errorView.hidden = true
        refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        self._loadMovieData(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let movieDetailsViewController = segue.destinationViewController as? MovieDetailsViewController else {
            return
        }
        guard let movieIndexPath = tableView.indexPathForCell(sender as! MovieTableViewCell) else {
            return
        }
        let movie = _getMovies()[movieIndexPath.row]
        guard let posterPath = movie["poster_path"] as? String else {
            return
        }
        movieDetailsViewController.movieImageUrl = NSURL(string: "http://image.tmdb.org/t/p/w500" + posterPath)
        movieDetailsViewController.movieDescription = movie["overview"] as? String
        movieDetailsViewController.movieTitle = movie["title"] as? String
        if let releaseDate = movie["release_date"] as? String {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.dateFromString(releaseDate) {
                dateFormatter.dateStyle = .LongStyle
                movieDetailsViewController.movieReleaseDate = dateFormatter.stringFromDate(date)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let movie = _getMovies()[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier("movieTableViewCellIdentifier", forIndexPath: indexPath) as! MovieTableViewCell
        
        // Set cell image (or remove it if not available)
        if let posterPath = movie["poster_path"] as? String {
            if let url = NSURL(string: "http://image.tmdb.org/t/p/w185" + posterPath) {
                cell.movieImageView.setImageWithURL(url)
            } else {
                cell.movieImageView.image = nil
            }
        }
        
        // Set the title and description
        cell.movieTitleLabel.text = movie["title"] as? String
        cell.movieDescriptionLabel.text = movie["overview"] as? String
        cell.movieDescriptionLabel.sizeToFit() // Reduce size of the description (if needed) so that
                                               // the label is vertically top aligned

        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._getMovies().count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated:true)
    }

}

class NowPlayingMoviesTableViewController: MoviesTableViewController {
    override func getAPIURL() -> String {
        return "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Now Playing"
    }
}

class TopRatedMoviesTableViewController: MoviesTableViewController {
    override func getAPIURL() -> String {
        return "https://api.themoviedb.org/3/movie/top_rated?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"
    }
}
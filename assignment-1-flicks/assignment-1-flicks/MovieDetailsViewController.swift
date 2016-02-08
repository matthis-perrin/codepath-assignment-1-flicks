//
//  MovieDetailsViewController.swift
//  assignment-1-flicks
//
//  Created by Matthis Perrin on 2/7/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class MovieDetailsViewController: UIViewController {

    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var detailsScrollView: UIScrollView!
    @IBOutlet weak var movieDescriptionLabel: UILabel!
    @IBOutlet weak var movieReleaseDateLabel: UILabel!
    @IBOutlet weak var movieTitleLabel: UILabel!
    
    internal var movieImageUrl: NSURL?
    internal var movieDescription: String?
    internal var movieTitle: String?
    internal var movieReleaseDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = movieTitle

        movieImageView.contentMode = .ScaleAspectFill
        if let movieImageUrl = movieImageUrl {
            movieImageView.setImageWithURL(movieImageUrl)
        }
        movieTitleLabel.text = movieTitle
        movieReleaseDateLabel.text = movieReleaseDate
        movieDescriptionLabel.text = movieDescription
        movieDescriptionLabel.sizeToFit()
        detailsScrollView.contentSize = CGSizeMake(375, 590 + movieDescriptionLabel.frame.height)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

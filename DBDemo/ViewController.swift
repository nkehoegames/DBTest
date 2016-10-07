//
//  ViewController.swift
//  DBDemo
//
//  Created by Gabriel Theodoropoulos on 5/8/15.
//  Copyright (c) 2015 Appcoda. All rights reserved.
//

import UIKit



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, DBRestClientDelegate {

    
    var dbRestClient: DBRestClient!
    
    var dropboxMetadata: DBMetadata!
    
    @IBOutlet weak var tblFiles: UITableView!
    
    @IBOutlet weak var bbiConnect: UIBarButtonItem!
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tblFiles.delegate = self
        tblFiles.dataSource = self
        
        progressBar.hidden = true
        
         NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidLinkNotification:", name: "didLinkToDropboxAccountNotification", object: nil)
        
        
        if DBSession.sharedSession().isLinked() {
            bbiConnect.title = "Disconnect"
            initDropboxRestClient()
        }
        
        // Verify user is logged into Dropbox
            }
    
    
    @IBAction func performAction(sender: AnyObject) {
        if !DBSession.sharedSession().isLinked() {
            print("You're not connected to Dropbox")
            return
        }
        
        let actionSheet = UIAlertController(title: "Upload file", message: "Select file to upload", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let uploadTextFileAction = UIAlertAction(title: "Upload text file", style: UIAlertActionStyle.Default) { (action) -> Void in
            
        }
        
        let uploadImageFileAction = UIAlertAction(title: "Upload image", style: UIAlertActionStyle.Default) { (action) -> Void in
             let sourcePath = NSBundle.mainBundle().pathForResource("nature", ofType: "jpg")
         
            self.showProgressBar()
            

            
            self.dbRestClient.uploadFile("test.png", toPath: "/", withParentRev: nil, fromPath: sourcePath) //What it was saved as, where?,what to upload
          
          
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(uploadTextFileAction)
        actionSheet.addAction(uploadImageFileAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    
    @IBAction func reloadFiles(sender: AnyObject) {
        dbRestClient.loadMetadata("/")
    }

    
    // MARK: UITableview method implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let metadata = dropboxMetadata {
            return metadata.contents.count
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("idCellFile", forIndexPath: indexPath) as! UITableViewCell
        
        let currentFile: DBMetadata = dropboxMetadata.contents[indexPath.row] as! DBMetadata
        cell.textLabel?.text = currentFile.filename
       // cell.imageView?.image = currentFile
        
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
         return 60.0
    }
    
    func handleDidLinkNotification(notification: NSNotification) {
        initDropboxRestClient()
        bbiConnect.title = "Disconnect"
    }
    
    func initDropboxRestClient() {
        dbRestClient = DBRestClient(session: DBSession.sharedSession())
        dbRestClient.delegate = self
        dbRestClient.loadMetadata("/") // Where to look
    }
    
    
    func showProgressBar() {
        progressBar.progress = 0.0
        progressBar.hidden = false
    }
    
    func restClient(client: DBRestClient!, uploadProgress progress: CGFloat, forFile destPath: String!, from srcPath: String!) {
        progressBar.progress = Float(progress)
    }
    
    
 
    func restClient(client: DBRestClient!, uploadedFile destPath: String!, from srcPath: String!, metadata: DBMetadata!) {
        print("The file has been uploaded.")
        print(metadata.path)
        progressBar.hidden = true
        dbRestClient.loadMetadata("/")
    }
    
    func restClient(client: DBRestClient!, uploadFileFailedWithError error: NSError!) {
        print("File upload failed.")
        print(error.description)
        progressBar.hidden = true
    }
    
    func restClient(client: DBRestClient!, loadedMetadata metadata: DBMetadata!) {
        dropboxMetadata = metadata;
        tblFiles.reloadData()
    }

    

    func restClient(client: DBRestClient!, loadMetadataFailedWithError error: NSError!) {
        print(error.description)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let selectedFile: DBMetadata = dropboxMetadata.contents[indexPath.row] as! DBMetadata
        
        let documentsDirectoryPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        
        showProgressBar()
        
        dbRestClient.loadFile(selectedFile.path, intoPath: documentsDirectoryPath as String)
    }
    
    func restClient(client: DBRestClient!, loadedFile destPath: String!, contentType: String!, metadata: DBMetadata!) {
        print("The file \(metadata.filename) was downloaded. Content type: \(contentType)")
        progressBar.hidden = true
    }
    
    func restClient(client: DBRestClient!, loadFileFailedWithError error: NSError!) {
        print(error.description)
        progressBar.hidden = true
    }
    
    func restClient(client: DBRestClient!, loadProgress progress: CGFloat, forFile destPath: String!) {
        progressBar.progress = Float(progress)
    }
    
    


}
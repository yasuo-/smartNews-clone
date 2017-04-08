//
//  News1ViewController.swift
//  SmartNews
//
//  Yahoo RSSのXMLデータをTableControllerに加えていく
//  Created by 栗原靖 on 2017/04/03.
//  Copyright © 2017年 Yasuo Kurihara. All rights reserved.
//

import UIKit

// UIViewController
// UITableViewDelegate
// UITableViewDataSource
// UIWebViewDelegate
// XMLParserDelegate
// これらのメソッドを使う宣言を行う
class News1ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate, XMLParserDelegate {
    
    // tableView
    var tableView: UITableView = UITableView()
    
    // 引っ張ってロード
    var refreshControl: UIRefreshControl!
    
    // webView
    var webView: UIWebView = UIWebView()
    
    // goButton
    var goButton: UIButton!
    
    // back Button
    var backButton: UIButton!
    
    // cancel Button
    var cancelButton: UIButton!
    
    // dots view
    var dotsView: DotsLoader! = DotsLoader()
    
    // parser
    var parser = XMLParser()
    // 両方入るもの
    var totalBox = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = String()
    var titleString = NSMutableString()
    var linkString = NSMutableString()
    
    

    // はじめに画面が呼ばれた時に出るもの
    override func viewDidLoad() {
        super.viewDidLoad()

        // コードでviewを作る
        // 背景画像を作る
        let imageView = UIImageView()
        // 画面いっぱい広げる
        imageView.frame = self.view.bounds
        imageView.image = UIImage(named: "1.jpg")
        // 画面に貼り付ける
        self.view.addSubview(imageView)
        
        
        // 引っ張って更新
        refreshControl = UIRefreshControl()
        // ローディングの色
        refreshControl.tintColor = UIColor.white
        // どのメソッド => 自分
        //
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControlEvents.valueChanged)
        
        
        // tableViewを作成する
        tableView.delegate = self
        tableView.dataSource = self
        // x,y軸
        // width => 自分のviewの全体の幅
        // height => 自分のviewの全体の高さ - 54.0(tabの高さ分)
        tableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height - 54.0)
        // 背景をクリアにすると画像が透けて見える (デフォルトは白)
        tableView.backgroundColor = UIColor.clear
        // tableViewとrefreshViewが合体する
        tableView.addSubview(refreshControl)
        // 自分の画面をつける refreshControlが付いている
        self.view.addSubview(tableView)
        
        
        // webViewの作成
        // 大きさ tableViewの大きさにする
        webView.frame = tableView.frame
        webView.delegate = self
        webView.scalesPageToFit = true//self
        // .scaleAspectFit　=> 画面の中に収まる
        webView.contentMode = .scaleAspectFit
        self.view.addSubview(webView)
        // はじめに画面が呼ばれた時にwebViewがあるのは今回はだめ
        // Hiddenにしておく
        webView.isHidden = true
        // webViewを表示するのはtableViewのcellを押した時
        // 対象のLinkを表示する
        
        
        
        // 1つ進むbutton作成
        goButton = UIButton()
        // frameを決める
        goButton.frame = CGRect(x: self.view.frame.size.width - 50, y: self.view.frame.size.height - 128, width: 50, height: 50)
        // 画像つける for => どういう状態の時に表示するか
        goButton.setImage(UIImage(named: "go.png"), for: .normal)
        // .touchUpInside => ボタンを押して離した
        goButton.addTarget(self, action: #selector(nextPage), for: .touchUpInside)
        // 画面に付ける
        self.view.addSubview(goButton)
        
        
        // 戻るボタンの作成
        backButton = UIButton()
        backButton.frame = CGRect(x: 10, y: self.view.frame.size.height - 128, width: 50, height: 50)
        backButton.setImage(UIImage(named: "back.png"), for: .normal)
        backButton.addTarget(self, action: #selector(backPage), for: .touchUpInside)
        self.view.addSubview(backButton)
        
        
        // キャンセルボタンの作成
        cancelButton = UIButton()
        cancelButton.frame = CGRect(x: 10, y: 80, width: 50, height: 50)
        cancelButton.setImage(UIImage(named: "cancel.png"), for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.view.addSubview(cancelButton)
        
        
        //　作成したボタンをisHidden = trueにする
        goButton.isHidden = true
        backButton.isHidden = true
        cancelButton.isHidden = true
        
        
        // ドッツビューの作成
        dotsView.frame = CGRect(x: 0, y: self.view.frame.size.height / 3, width: self.view.frame.size.width, height: 100)
        // 個数
        dotsView.dotsCount = 5
        // 大きさ
        dotsView.dotsRadius = 10
        // くっつける
        self.view.addSubview(dotsView)
        
        
        // hiddenにする
        dotsView.isHidden = true
        
        
        // XMLを解析する(パース)
        // parser
        let url: String = "http://news.yahoo.co.jp/pickup/domestic/rss.xml"
        let urlToSend: URL = URL(string: url)!
        parser = XMLParser(contentsOf: urlToSend)!
        totalBox = []
        parser.delegate = self
        // 解析する
        parser.parse()
        // 更新がされる
        tableView.reloadData()
        
        
        
        
        
        // Do any additional setup after loading the view.
    }
    
    // refresh
    // 下から上に引っ張った時呼ばれる
    func refresh() {
        // どれだけ時間をおいて元に戻すか 2.0 => 2秒後
        perform(#selector(delay), with: nil, afterDelay: 2.0)
        
    }
    
    // delay
    func delay() {
        
        // XMLを解析する(パース)
        // parser
        let url: String = "http://news.yahoo.co.jp/pickup/domestic/rss.xml"
        let urlToSend: URL = URL(string: url)!
        parser = XMLParser(contentsOf: urlToSend)!
        totalBox = []
        parser.delegate = self
        // 解析する
        parser.parse()
        // 更新がされる
        tableView.reloadData()
        
        
        // リフレッシュを終わらせる
        refreshControl.endRefreshing()
    }
    
    // nextPage
    // webViewを1page進める
    func nextPage() {
        
        webView.goForward()
    }
    
    // backPage
    // webViewを1ページ戻す
    func backPage() {
        
        webView.goBack()
    }
    
    // cancel
    // webViewを隠す
    func cancel() {
        
        webView.isHidden = true
        goButton.isHidden = true
        backButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    // tableviewのデリゲート
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return totalBox.count
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        
        cell.backgroundColor = UIColor.clear

        cell.textLabel?.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "title") as? String
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 15.0)
        cell.textLabel?.textColor = UIColor.white
        
        
        cell.detailTextLabel?.text = (totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String
        cell.detailTextLabel?.font = UIFont.boldSystemFont(ofSize: 9.0)
        cell.detailTextLabel?.textColor = UIColor.white
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // WebViewを表示する
        let linkURL = (totalBox[indexPath.row] as AnyObject).value(forKey: "link") as? String
        let urlStr = linkURL?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url: URL = URL(string: urlStr!)!
        let urlRequest = NSURLRequest(url: url)
        
        webView.loadRequest(urlRequest as URLRequest)
        
    }
    
    // webViewDidStartLoad
    // load スタート
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        dotsView.isHidden = false
        dotsView.startAnimating()
        
    }

    // webViewDidFinishLoad
    // load 終わったら
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        dotsView.isHidden = true
        dotsView.stopAnimating()
        webView.isHidden = false
        goButton.isHidden = false
        backButton.isHidden = false
        cancelButton.isHidden = false
        
    }
    
    // タグを見つけた時
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        // elementにelementNameを入れて行く
        element = elementName
        
        if element == "item" {
            
            elements = NSMutableDictionary()
            elements = [:]
            titleString = NSMutableString()
            titleString = ""
            linkString = NSMutableString()
            linkString = ""
            
        }
    }
    
    // タグの間にデータがあった時(開始タグと終了タグでくくられた箇所にデータが存在した時に実行されるメソッド)
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        if element == "title" {
            
            titleString.append(string)
            
        } else if element == "link" {
            
            linkString.append(string)
            
        }
    }
    
    
    // タグの終了を見つけた時
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        // itemという要素の中にあるなら
        if elementName == "item" {
            
            // titleString(linkString)の中身が空でないなら
        
            if titleString != "" {
                
                
                // elementsにkeyを付与しながらtitleString(linkStirng)をセットする
                elements.setObject(titleString, forKey: "title" as NSCopying)
            }
            
            if linkString != "" {
                
                // elementsにkeyを付与しながらtitleString(linkStirng)をセットする
                
                elements.setObject(linkString, forKey: "link" as NSCopying)
            }
            
            
            // totalBoxの中にelementsを入れる
            totalBox.add(elements)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

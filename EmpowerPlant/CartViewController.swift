//
//  CartViewController.swift
//  EmpowerPlant
//
//  Created by William Capozzoli on 3/8/22.
//

import UIKit
import Sentry

class CartViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cart Screen"
        
        self.view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        // Comment this out and to see the green background and no data in the rows
        tableView.frame = view.bounds
        
        configureNavigationItems()
        
        // TODO make this 'total' appear in a UI element
        print("CartViewController | TOTAL", ShoppingCart.instance.total)
    }
    
    private func configureNavigationItems() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Checkout",
            style: .plain,
            target: self,
            action: #selector(checkout)
        )
    }
    
    @objc
    func checkout() {
        let transaction = SentrySDK.startTransaction(
          name: "checkout",
          operation: "http.client",
          bindToScope: true
        )
        
        let url = URL(string: "https://application-monitoring-flask-dot-sales-engineering-sf.appspot.com/checkout")!
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("will1", forHTTPHeaderField: "se")
        request.setValue("will@abc.com", forHTTPHeaderField: "email")
        request.httpMethod = "POST"
        
        let json: [String: Any] = [
            "form": ["email":"will@chat.io"],
            "cart": [
                "total": 100,
                "quantities": ["4": 3],
                "items": [
                    ["id":"4", "title":"Plant Nodes"]
                    // ["id":"5", "title":"Plant Stroller"]
                ]
            ],
        ]
        
        let bodyData = try? JSONSerialization.data(
            withJSONObject: setJson(),
            options: []
        )
        request.httpBody = bodyData
        
        enum CheckoutError: Error {
            case insufficientInventory
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let httpResponse = response as? HTTPURLResponse {
                if (httpResponse.statusCode) == 500 {
                    print("> 500 response")
                    let err = CheckoutError.insufficientInventory
                    SentrySDK.capture(error: err)
                }
            }
            transaction.finish()
        }
        
        task.resume()
    }
    
    // total, quantities, items
    func setJson() -> [String: Any] {
        
        // total DONE
        // quantities DONE below
        // items TODO
        
        let json: [String: Any] = [
            "form": ["email":"will@chat.io"], // TODO email update + check if all tx's+errors have email
            "cart": [
                "total": ShoppingCart.instance.total,
                "quantities": [
                    "3": ShoppingCart.instance.quantities.plantMood,
                    "4": ShoppingCart.instance.quantities.botanaVoice,
                    "5": ShoppingCart.instance.quantities.plantStroller,
                    "6": ShoppingCart.instance.quantities.plantNodes,
                ],
                "items": [
                    ["id":"4", "title":"Plant Nodes"]
                    // ["id":"5", "title":"Plant Stroller"]
                ]
            ],
        ]
        
        return json
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // TODO could compute the length based on length of quantities.botanaVoice, plantStroller, nodeVoices, etc.
        // or continue showing all products, even if quantity is 0. the screen looks more full this way
        return 4 // products.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //  'product' here has all available attributes here, if needed in the future (e.g. UI development)
        // let product = products[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        var items: [Int] = [
            ShoppingCart.instance.quantities.plantMood,
            ShoppingCart.instance.quantities.botanaVoice,
            ShoppingCart.instance.quantities.plantStroller,
            ShoppingCart.instance.quantities.plantNodes,
        ]
        
        var text = ""
        var quantity = items[indexPath.row]

        switch indexPath.row {
        case 0:
            text = "Plant Mood: " + String(quantity)
            break
        case 1:
            text = "Botana Voice: " + String(quantity)
            break
        case 2:
            text = "Plant Stroller: " + String(quantity)
            break
        case 3:
            text = "Plant Nodes: " + String(quantity)
            break
        default:
            print("indexPath.row was not 0,1,2,3")
        }
        
        cell.textLabel?.text = text
        
        return cell
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

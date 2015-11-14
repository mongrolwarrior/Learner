import Foundation
import WatchKit

protocol ModalItemChooserDelegate {
    func didSelectItem(itemSelected:String)
}

class DeleteQuestion: WKInterfaceController {
    var delegate: ViewController?
    
    @IBOutlet var labelLabel: WKInterfaceLabel!
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        self.delegate = context as? ViewController
        // Configure interface objects here.
        print(delegate)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        
        super.willActivate()
        
        labelLabel.setText(self.delegate?.currentQuestion.qid?.stringValue)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
}
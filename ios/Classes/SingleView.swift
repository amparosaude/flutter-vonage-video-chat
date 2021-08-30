import SwiftUI

struct SingleView : View {
    var body: some View{
        ZStack{
            Color.black
        }
    }
}

var subscriberNoCameraChild = UIHostingController(rootView: SingleView())

var publisherNoCameraChild = UIHostingController(rootView: SingleView())

struct SingleView_Preview: PreviewProvider {
    static var previews: some View {
        SingleView()
    }
}

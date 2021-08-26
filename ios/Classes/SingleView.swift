import SwiftUI

struct SingleView : View {
    var body: some View{
        ZStack{
            Color.black
        }
    }
}

var child = UIHostingController(rootView: SingleView())

struct SingleView_Preview: PreviewProvider {
    static var previews: some View {
        SingleView()
    }
}

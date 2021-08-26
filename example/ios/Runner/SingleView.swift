//
//  SingleView.swift
//  Runner
//
//  Created by Gustavo Cesar on 25/08/21.
//

import SwiftUI

struct SingleView: View {
    var body: some View {
        ZStack{
            Color.black
            Image("videocam_off").resizable().scaledToFit()
        }
    }
}

struct SingleView_Previews: PreviewProvider {
    static var previews: some View {
        SingleView()
    }
}

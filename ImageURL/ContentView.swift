//
//  ContentView.swift
//  ImageURL
//
//  Created by Shubham Kamdi on 4/6/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var vm = ViewModel()
    @State var dataLRU: [URL] = []
    @State var lruContext: LRU.Context? = nil
    @State var dataToEnter: String = ""
    @State var fetchingBatched: Bool = true
    let images = [
        "https://fastly.picsum.photos/id/94/200/300.jpg?hmac=CA7x5S3EdSeRqM9TK0RxiKTcx1R96lIncvKTjTP3beI",
        "https://fastly.picsum.photos/id/663/200/300.jpg?hmac=OYPBwsRmaygvAiTN0M4ZNNWBZqgbTGuH2aXkJ4FLX_M",
        "https://fastly.picsum.photos/id/594/200/300.jpg?hmac=kcNk6N4hJqRhoKUJ8ZeFWLMVV-2_Z5hLfxCFEyrsAx4",
        "https://fastly.picsum.photos/id/381/200/300.jpg?hmac=DHcGsLBoQPJC-_rudxS4AdZuSE9UoOFP2U2v2veUAok",
        "https://fastly.picsum.photos/id/685/200/300.jpg?hmac=0R7Bu0AY8CbakSrvbQHtFb_swiFQbJqQe7bKpbV6viA",
        "https://fastly.picsum.photos/id/166/200/300.jpg?hmac=tt6C1FuYJwyz0in9uZ9vFTADVlaezHjouGMPh60xVVo",
        "https://fastly.picsum.photos/id/219/200/300.jpg?hmac=RGnJfbO2380zLCFSj2tm_q0vW0wtw67d0fhWHX2IoDk",
        "https://fastly.picsum.photos/id/309/200/300.jpg?hmac=gmsts4-400Ihde9dfkfZtd2pQnbZorV4nBKlLOhbuMs",
        "https://fastly.picsum.photos/id/366/200/300.jpg?hmac=DSwBED2NJAjXrxxpoaV9bSb7mk2FlPwa03WwDJ6VcdQ",
        "https://fastly.picsum.photos/id/948/200/300.jpg?hmac=P3pbS5OFe3xlh-_nxsMU3WRWDS5lXF_rBKQZIL_7wPo",
        "https://fastly.picsum.photos/id/966/200/300.jpg?hmac=vBALR2x0cV-keVNLecwjd8ZluSHv17AHDvpiYjBqar0",
        "https://fastly.picsum.photos/id/223/200/300.jpg?hmac=IZftr2PJy4auHpfBpLuMtFhsxgQYlUgXdV5rFwjGItQ",
        "https://fastly.picsum.photos/id/648/200/300.jpg?hmac=yifVKULNJZhxFK2Oav2kDH8G4unUDKn-OebXR1bWOf4",
        "https://fastly.picsum.photos/id/134/200/300.jpg?hmac=KN18cCDft4FPM0XJpr7EhZLtUP6Z4cZqtF8KThtTvsI",
        "https://fastly.picsum.photos/id/1028/200/300.jpg?hmac=Ka86H0yLDb-Ft8SNNKSVTSFylu-GfaEGBrS2AP01ZSM",
        "https://fastly.picsum.photos/id/721/200/300.jpg?hmac=6g_vLTUju_TGWN7cMKTjZgzqps-JjmHIS0KSuFsgVyc",
        "https://fastly.picsum.photos/id/627/200/300.jpg?hmac=C6cEU431ILuZjftVFQ1RsBlFYS52ym9f2KZPSOfH-R4",
        "https://fastly.picsum.photos/id/617/200/300.jpg?hmac=WVwPHGFiGQ3OhdyeRk0pQ82EUCJuksc-Zf7YjirDr9Q",
        "https://fastly.picsum.photos/id/134/200/300.jpg?hmac=KN18cCDft4FPM0XJpr7EhZLtUP6Z4cZqtF8KThtTvsI",
        "https://fastly.picsum.photos/id/351/200/300.jpg?hmac=OSQYmRI8IZkaMcC4ERotpBhe0AymVYajIIKPJFDzGBY",
        "https://fastly.picsum.photos/id/862/200/300.jpg?hmac=eu7Z4fgzcdsbc3tA4GZZVHdkM3dtNIu2A--ZHUQEK_g",
        "https://fastly.picsum.photos/id/803/200/300.jpg?hmac=v-3AsAcUOG4kCDsLMlWF9_3Xa2DTODGyKLggZNvReno",
        "https://fastly.picsum.photos/id/71/200/300.jpg?hmac=gynXVv0pTO33farflQTb9mpn-A6N5nt8t0_r9DEDNKU",
        "https://fastly.picsum.photos/id/79/200/300.jpg?hmac=uqOMZrx9qlolrYp0xS5t84xjCiD_BIjfxIugTa1xjho",
        "https://fastly.picsum.photos/id/131/200/300.jpg?hmac=9q7mRSOguNBFGg_gPPRKlfjNINGjXWeDBTYPP1_gEas",
        "https://fastly.picsum.photos/id/49/200/300.jpg?hmac=mC_cJaZJfrb4JZcnITvz0OOwLCyOTLC0QXH4vTo9syY",
        "https://fastly.picsum.photos/id/580/200/300.jpg?hmac=ETV-og2PgiTBmJBERthfeRRRuLpWGxM4Zq_3z8pXndA",
        "https://fastly.picsum.photos/id/857/200/300.jpg?hmac=kFf6koUaHH4bIVWuoXIIsmZJQM_9Ew5l4AOeLL2UoG8",
        "https://fastly.picsum.photos/id/548/200/300.jpg?hmac=dXVAc-s_U8QgoYUrMld43VmrOby1cluk-akWgxY6b9Y",
        "https://fastly.picsum.photos/id/218/200/300.jpg?hmac=S2tW-K1x-k9tZ7xyNVAdnie_NW9LJEby6GBgYpL7kfo",
        "https://fastly.picsum.photos/id/723/200/300.jpg?hmac=EtJwe3DxhZ1GDiNghxWaO92pvcPcjg02wJzc7Qj7Lr0",
        "https://fastly.picsum.photos/id/1084/200/300.jpg?hmac=JQMQbKvpN6_d6r-fiuOEYe1Dz6f2gfGIkTvsx0nLJUQ",
        "https://fastly.picsum.photos/id/41/200/300.jpg?hmac=oimmvNf5GBZCx44LN9J4KGnDqUvSWmmUwPcLUaUMxF0",
        "https://fastly.picsum.photos/id/544/200/300.jpg?hmac=YL3M_fg_84Kqg0EQTvbltmjeGeQetARWPFA5YLn5hS0",
        "https://fastly.picsum.photos/id/927/200/300.jpg?hmac=QPcp-v-pSMdg7Ly4-wWB7E0es9E0WWk9ll_YTYNeb_w",
        "https://fastly.picsum.photos/id/1076/200/300.jpg?hmac=v-yXySfuFZmvrYNvyAps4V02kbxa1_XuprgoVVsj4ZQ",
        "https://fastly.picsum.photos/id/737/200/300.jpg?hmac=_AgsmIPnE5n0TW6DlnkHjaBM-pOhLbzZYyQQk8xzH8M",
        "https://fastly.picsum.photos/id/646/200/300.jpg?hmac=qCJ0bf6G6oSxx8YMMc1ZLVryK-w596XjRD3o8cXQLFc",
        "https://fastly.picsum.photos/id/32/200/300.jpg?hmac=rNLw7Y7-RK2isGxXfSq90mzxSpKSXsRuOkvkGdEGK9c",
        "https://fastly.picsum.photos/id/621/200/300.jpg?hmac=GgxwZqdPsVQwlM2QhfHoLU8gZ7uo_PP6oD4KmIq-ino",
        "https://fastly.picsum.photos/id/724/200/300.jpg?hmac=MwcEnqDDOgKg6U3WYPytBPH_jurNEK2_2kcknpgP6wg",
        "https://fastly.picsum.photos/id/608/200/300.jpg?hmac=b-eDmVyhr3rI_4k3z2J_PNwOxEwSKa5EDC9uFH4jERU",
        "https://fastly.picsum.photos/id/602/200/300.jpg?hmac=TkzlF12MtJomcmqzsOc-CR43gSl3xnotDQRPBvM7Avw",
        "https://fastly.picsum.photos/id/576/200/300.jpg?hmac=Uf-okGnisfAphCT3N-WTyzaG-e-r9yvOhY3W43DMWwA",
        "https://fastly.picsum.photos/id/716/200/300.jpg?hmac=qbNS_afUKsp_nyvuAAcK8T7OxOtMoqJvLIeaK-jirsU",
        "https://fastly.picsum.photos/id/884/200/300.jpg?hmac=VnWK-J-znCMSx2FSelz3LtT1DXhrxRLtzsX6-hkZDJk",
        "https://fastly.picsum.photos/id/327/200/300.jpg?hmac=4XafWFg8DGNzz5ATxgKAXnhZmeCXdFEtK86ehmyQlE4",
        "https://fastly.picsum.photos/id/485/200/300.jpg?hmac=Kv8DZbgB5jppYcdfZdMVu2LM3XAIt-3fvR8VcmrLYhw",
        "https://fastly.picsum.photos/id/221/200/300.jpg?hmac=vFrrajnPFCrr5ttjepVTsUDWzoo-orpnXOsqdqAd0LU",
        "https://fastly.picsum.photos/id/429/200/300.jpg?hmac=6ShrHCg_ioSEwdK2j-TkxO08G50YITxb2h0Z42Y8piI",
        "https://fastly.picsum.photos/id/39/200/300.jpg?hmac=CcUiRU6-82MldMqtiF9shpKCbwzwkILEWuRi90JsADs",
        "https://fastly.picsum.photos/id/1057/200/300.jpg?hmac=NbjAWVAsLFsIna7Sw8vp4X2BhTpao1KbwORuUZlAcWw",
        "https://fastly.picsum.photos/id/240/200/300.jpg?hmac=oqwZqcYrZ2nqhtDKiob6qVc3u_vuKLh89nVzKs_jnNg",
        "https://fastly.picsum.photos/id/327/200/300.jpg?hmac=4XafWFg8DGNzz5ATxgKAXnhZmeCXdFEtK86ehmyQlE4",
        "https://fastly.picsum.photos/id/16/200/300.jpg?hmac=k64O1qCMBhaU0Ep_qML5_xDxqLVR1MhNm8VMqgdAsxA",
        "https://fastly.picsum.photos/id/16/200/300.jpg?hmac=k64O1qCMBhaU0Ep_qML5_xDxqLVR1MhNm8VMqgdAsxA",
        "https://fastly.picsum.photos/id/605/200/300.jpg?hmac=XxO9Fq91nFhrH3zq-9AlrpU84EnKslY5CeTA_6dBlRg",
        "https://fastly.picsum.photos/id/139/200/300.jpg?hmac=LFfuwfbYa2mo__RoCuyS9ujrwnHgF5c4AXDiCs3JNZ0",
        "https://fastly.picsum.photos/id/46/200/300.jpg?hmac=hO6W_-hkJCRf3aWSzs0SkaWPFlMhZsixxrObPW_sFaY",
        "https://fastly.picsum.photos/id/698/200/300.jpg?hmac=2Z_fr-yUH1ByQu36MAR319aTCndT4FjG1VBksAKGVKU",
        "https://fastly.picsum.photos/id/214/200/300.jpg?hmac=XWc2pr4xabaprbyVoKEw9VsBDZ0ibySoVWMJaKokGRU",
        "https://fastly.picsum.photos/id/443/200/300.jpg?hmac=lXwP6DouUwgwHCQ9ZcgkX6W237U8PAyS9o-YAD1zvN8",
        "https://fastly.picsum.photos/id/545/200/300.jpg?hmac=mKTuqg7uMMnQbx-G17z5e7tJrjfkYtqbsfRm_dCrCfQ",
        "https://fastly.picsum.photos/id/692/200/300.jpg?hmac=qoaBsJRR_eEfM9cuFXDECrJYjrebuLirYg5r7H_VVok",
        "https://fastly.picsum.photos/id/839/200/300.jpg?hmac=6Q1AIZuZ4Zsy0Wa1Uc-FvgyhjmS1liv_dhSoh7ItyLY",
        "https://fastly.picsum.photos/id/39/200/300.jpg?hmac=CcUiRU6-82MldMqtiF9shpKCbwzwkILEWuRi90JsADs",
        "https://fastly.picsum.photos/id/666/200/300.jpg?hmac=FfmCCw-UuMgMhTLigoNVx2auMxtw-EtixqVwwxaefq0",
        "https://fastly.picsum.photos/id/1023/200/300.jpg?hmac=Z31cf_3ve4den6NwDN7ITqRf_DTVTsQlt5aZMpVi5Wk",
        "https://fastly.picsum.photos/id/5/200/300.jpg?hmac=1TWjKFT7_MRP0ApEyDUA3eCP0HXaKTWJfHgVjwGNoZU",
        "https://fastly.picsum.photos/id/416/200/300.jpg?hmac=KIMUiPYQ0X2OQBuJIwtfL9ci1AGeu2OqrBH4GqpE7Bc",
        "https://fastly.picsum.photos/id/112/200/300.jpg?hmac=2Y23MnaG65tK7HHRGB9XvjPcMETuBqK4fiu8t5rbBdg",
        "https://fastly.picsum.photos/id/760/200/300.jpg?hmac=V3yvSu3sykZMdt6gvj7uKDb8WPm1mltpcdIah8vfZpU",
        "https://fastly.picsum.photos/id/1018/200/300.jpg?hmac=IrYgAIczHOxOgmWliW3MlASD3LdAJ_aHAdh5f2aY9Sw",
        "https://fastly.picsum.photos/id/873/200/300.jpg?hmac=CQHrOY67pytIwHLic3cAxphNbh2NwdxnFQtwaX5MLkM",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
//        "",
        
    ]
    var body: some View {
        
        VStack {
            nativeList
            VStack {
                Text("LRU_Metrics")
                HStack {
                    Spacer().frame(width: 15)
                    Text("Hit: \(lruContext?.hitLRU ?? 0)")
                    Spacer().frame(width: 15)
                }
                HStack {
                    Spacer().frame(width: 15)
                    Text("Revoked: \(lruContext?.revokedFromLRU ?? 0)")
                    Spacer().frame(width: 15)
                }
                HStack {
                    Spacer().frame(width: 15)
                    Text("Request Count: \(lruContext?.requestLRU ?? 0)")
                    Spacer().frame(width: 15)
                }
                HStack {
                    Spacer().frame(width: 15)
                    Text("Missed Count: \(lruContext?.missed ?? 0)")
                    Spacer().frame(width: 15)
                }
            }
            .onReceive(LRU.metrics.context) { pub in
                if let pub {
                    withAnimation {
                        self.lruContext = pub
                    }
                }
            }
            
        }
        
    }
    
    @ViewBuilder
    var batchedDL: some View {
        if fetchingBatched {
            Text("Testing")
                .onAppear(perform: {
                    vm.setQuatity()
                    Task {
                        let _ = try? await ImageDL.utility.batchDownload(withPriority: .high, images: images)
                        await MainActor.run { withAnimation { fetchingBatched = false } }
                    }
                    
                })
        } else {
            lruList
        }
    }
    
    @State var wait: Bool = false
    var nativeList: some View {
        
        List {
            if wait {
                
            } else {
                
            }
            ForEach(0 ..< images.count, id: \.self) { i in
                Image(uiImage: UIImage(data: try! Data(contentsOf: URL(string: images[i])!))!)
            }
        }
    }
    
    var lruList: some View {
        List {
            ForEach(0 ..< images.count, id: \.self) { i in
                LRUImage(url: URL(string: images[i])!)
            }
        }
    }
    
    var list: some View {
        List() {
            HStack {
                Spacer().frame(width: 20)
                Text("Add Data")
                Spacer()
                TextField("Add to LRU", text: $dataToEnter)
                
                Spacer().frame(width: 20)
            }.submitLabel(.done)
                .onSubmit {
                    vm.addData(dataToEnter)
                    dataToEnter = ""
                    vm.ver2GetData()
                }
            ForEach(0 ..< dataLRU.count, id: \.self) { i in
                HStack {
                    Image(uiImage: UIImage(data: try! Data(contentsOf: dataLRU[i], options: .mappedIfSafe))!)
                    Text("\(i + 1)")
                }
            }
        }.listStyle(InsetGroupedListStyle())
            .onReceive(vm.$dataPUB, perform: { data in
                if data.count > 0 {
                    withAnimation {
                        self.dataLRU = data
                        print("Data: \(dataLRU)")
                    }
                }
            })
    }
    
    
    func createImage(_ url: URL) -> (any View)? {
        var returnableView: (any View)? {
            didSet {
                
            }
        }
        Task {
            if let image = try await vm.downloadImage(url),
               let data = try? Data(contentsOf: image, options: .mappedIfSafe),
               let displayImage = UIImage(data: data) {
                await MainActor.run {
                    returnableView = Image(uiImage: displayImage)
                }
            } else {
                returnableView = Text("LOADING...")
            }
        }
        return returnableView
    }
}

class ViewModel: ObservableObject {
    
    var src2 = LRUV2.shared
    @Published var dataPUB: [URL] = []
    
    func addData(_ data: String) {
        if let url = URL(string: data) {
            downloadImage(url)
        }
       
    }
    
    func setQuatity() {
        print("Set")
        Task {
            await src2.set(100)
        }
        
    }
    
    func ver2GetData() {
        //dataPUB = []
        //dataPUB = src2.getData()
    }
    
    //https://fastly.picsum.photos/id/366/200/300.jpg?hmac=DSwBED2NJAjXrxxpoaV9bSb7mk2FlPwa03WwDJ6VcdQ
    //https://picsum.photos/200/300
    func downloadImage(_ url: URL) {
        Task {
            if let url = await LRUV2.shared.get(url) {
                await MainActor.run {
                    print("DLImge: Prior \(dataPUB.count) \(dataPUB)")
                    dataPUB += [url]
                    print("DLImge: \(url) \(dataPUB.count)")
                }
            } else {
                if let url = try? await ImageDL.utility.singleDownload(
                    image: url
                ) {
                    await MainActor.run {
                        dataPUB += [url]
                    }
                }
            }
        }
    }
    
    func downloadImage(
        _ url: URL
    ) async throws -> URL? {
        if let url = await LRUV2.shared.get(url) {
            return url
        } else if let url = try? await ImageDL.utility.singleDownload(
            image: url
        ) {
            return url
        }
        return nil
    }
}



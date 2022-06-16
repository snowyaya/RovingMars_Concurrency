/// Copyright (c) 2022 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import SwiftUI

struct LatestView: View {
  @State var latestPhotos: [Photo] = []
  let marsData = MarsData()
  
  var body: some View {
    NavigationView {
      ZStack {
        // 1
        ScrollView(.horizontal) {
          HStack(spacing: 0) {
            ForEach(latestPhotos) { photo in
              MarsImageView(photo: photo)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
            }
          }
          // 1
          .task {
            // 2
            latestPhotos = []
            latestPhotos = await marsData.fetchLatestPhotos()
          }
        }
        // 2
        if latestPhotos.isEmpty {
          MarsProgressView()
        }
      }
      .navigationTitle("Latest Photos")
    }
  }
}

// 1 Return a list of Photo
func latestPhotos(rover: String) async throws -> [Photo] {
  // 2
  let apiRequest = APIRequest<LatestPhotos>(
    urlString: "https://api.nasa.gov/mars-photos/api/v1/rovers/\(rover)/latest_photos"
  )
  let source = MarsRoverAPI()
  // 3
  let container = try await source.request(apiRequest, apiKey: source.apiKey)
  // 4
  return container.photos
}


struct LatestView_Previews: PreviewProvider {
  static var previews: some View {
    LatestView()
  }
}

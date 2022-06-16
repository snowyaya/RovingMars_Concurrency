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

// You’ll use this class to encapsulate all the tasks the views need to perform.
// It contains a reference to the MarsRoverAPI so you can make API calls.

import SwiftUI
import OSLog

class MarsData {
  let marsRoverAPI = MarsRoverAPI()
  
  func fetchAllRovers() async -> [Rover] {
    do {
      return try await marsRoverAPI.allRovers()
    } catch {
      log.error("Error fetching rovers: \(String(describing: error))")
      return []
    }
  }

  // 1
  func fetchLatestPhotos() async -> [Photo] {
    // 2
    // use withTaskGroup(of:returning:body:) to create the task group and specify that each task in the group will return an optional Photo
    await withTaskGroup(of: Photo?.self) { group in
      let rovers = await fetchAllRovers()

      // 1
      for rover in rovers {
        // 2
        group.addTask {
          // 3
          let photos = try? await self.marsRoverAPI.latestPhotos(rover: rover)
          return photos?.first
        }
      }
      // 1
      var latestPhotos: [Photo] = []
      // 2
      for await result in group {
        // 3
        if let photo = result {
          latestPhotos.append(photo)
        }
      }
      // 4
      return latestPhotos
    }
  }

  // 1
  func fetchPhotoManifests() async throws -> [PhotoManifest] {
    // 2
    return try await withThrowingTaskGroup(of: PhotoManifest.self) { group in
      let rovers = await fetchAllRovers()
      // 3
      try Task.checkCancellation()
      // 4
      for rover in rovers {
        group.addTask {
          return try await self.marsRoverAPI.photoManifest(rover: rover)
        }
      }
      // 5 Using reduce(into:_:) is another way to loop through each task result and create an array to return.
      return try await group.reduce(into: []) { manifestArray, manifest in
        manifestArray.append(manifest)
      }
    }
  }
  
  func fetchPhotos(roverName: String, sol: Int) async -> [Photo] {
    do {
      return try await marsRoverAPI.photos(roverName: roverName, sol: sol)
    } catch {
      log.error("Error fetching rover photos: \(String(describing: error))")
      return []
    }
  }


}

## About
### What is SharePlayMock
  SharePlayMock is an extension API of Apple's GroupActivities API. The goal of SharePlayMock is to make testing SharePlay feature of visionOS apps easier.

  Without SharePlayMock, the only way to test a visionOS app's SharePlay feature is to ask a friend who has a vision pro to test with you, because you need to be in a FaceTime call to enable SharePlay. 
  
  However, SharePlay, at the essence, is just a message channel that helps you send messages to and receive messages from others in the same SharePlay session. 
  
  SharePlayMock, when enabled, establishes message channles using WebSocket among all participants, so that FaceTime call is not required anymore for testing. When SharePlayMock is disabled, the messages go through the official real SharePlay.
  
  With SharePlayMock, developers can test their multiplayer logics themselves by running an app instance on the simulator and another app instance on the vision pro device. 
  
  (In Xcode, you can run multiple instances at the same time on different targets)

### Use Cases & Limitations
  SharePlayMock helps you test your multiplayer logics, such as syncing the sphere size in the tutorial app, or syncing card positions in a card game. 
  
  However it does not help with testing positioning of participants, for example whether they are side-by-side or surrounding or what the distance is between the volume and the participants. You need to update to visionOS 2.0 to test the positioning logic.

## APIs & Example Code

On a high level, you use SharePlayMock by replacing various SharePlay identifiers (e.g. `GroupActivity`) with their SharePlayMock counterpart (e.g. `GroupActivityMock`).

1. **GroupActivityMock**<br>
    <pre><code>
    class PlayTogetherGroupActivity: GroupActivityMock {
           
      typealias ActivityType = PlayTogetherGroupActivity.Activity
             
      private(set) var groupActivity: Activity
             
      init() {
        self.groupActivity = Activity()
      }
             
      struct Activity: GroupActivity {
        // Define a unique activity identifier for system to reference
        static let activityIdentifier = "com.spatialdevs.SharePlayTutorial.PlayTogether"
             
        var metadata: GroupActivityMetadata {
          var metadata = GroupActivityMetadata()
          metadata.title = "Spatial Devs SharePlay Tutorial"
          metadata.subtitle = "Let's play together!"
          metadata.previewImage = UIImage(named: "birdicon")?.cgImage
          metadata.type = .generic
          return metadata
        }
      }
    }
    </code></pre>
2. **GroupSessionMock**
   ```
   var sharePlaySession: GroupSessionMock<PlayTogetherGroupActivity>?
   ```
3. **GroupSessionMessengerMock**
    ```
    var sharePlayMessenger: GroupSessionMessengerMock?
    ```
4. **GroupStateObserverMock**
    ```
    @ObservedObject var groupStateObserver = GroupStateObserverMock()
    ```
5. **ParticipantMock**
     ```
     func sendMessage<T: Codable>(_ message: T, to predicate: @escaping (ParticipantMock) -> Bool, inSequence: Bool = true) {
       if let participants = self.groupSession?.activeParticipants.filter(predicate),
         participants.isEmpty == false {
           self.sendMessage(message, to: Participants.only(participants), inSequence: inSequence)
         }
     }
     ```
6. **SystemCoordinatorMock**
     ```
     if let systemCoordinator = await session.systemCoordinator { // systemCoordinator has type SystemCoordinatorMock
       var configuration = SystemCoordinator.Configuration()
       configuration.supportsGroupImmersiveSpace = true
       configuration.spatialTemplatePreference = .conversational
       systemCoordinator.configuration = configuration
       
       self.tasks.insert(
          Task.detached { @MainActor in
              for await immersionStyle in systemCoordinator.groupImmersionStyle {
                  if let immersionStyle {
                      await openImmersiveSpace(id: "ImmersiveSpace")
                  } else {
                      await dismissImmersiveSpace()
                  }
              }
          }
      )
     }
     ```

## Integration Instructions
This instruction assumes you already have a visionOS project and used GroupActivities API and enabled SharePlay for your app/game.

For a more detailed tutorial, go [here](https://medium.com/@xinyichen0321/the-easiest-way-to-test-shareplay-on-visionos-apps-7bf8a1753d8e).

1. Download SharePlay Mock server (**We're working on a P2P version so you don't have to run a local server to do local testing**)
   1. Brew install java <br>
       ```
       brew install openjdk@17
       ```
   2. Download SharePlayMock Server jar file <br>
     [https://github.com/Pixeland-Tech/SharePlayMock/releases/tag/placeholder-tag-0.1.0](https://github.com/Pixeland-Tech/SharePlayMock/releases/tag/placeholder-tag-0.1.0) <br><br>
       > **Note:**
       > This repo does NOT include the source code of this jar file.
2. Add SharePlayMock package to project
   1. Open your visionOS project in Xcode
   2. Go to File -> Add Package Dependencies... -> Search or Enter Package URL -> Enter "[https://github.com/Pixeland-Tech/SharePlayMock](https://github.com/Pixeland-Tech/SharePlayMock)" -> Add Package
   3. Under "Add to Target", select your project, then click "Add Package"
3. Modify code
   1. Enable mock on App init
      ```
      struct SharePlayTutorialApp: App {
        init() {
          SharePlayMockManager.enable(webSocketUrl: "ws://<your_local_ip_address>:8080/endpoint") // e.g. ws://192.168.50.103:8080/endpoint
        }
        ...
      }
      ```
      To find out your local IP, go to System Settings -> Wi-Fi -> "Details" button of your connected wifi -> IP address
      
      > **Note:**
      > You need to manually enable/disable Mock. To disable Mock, simply comment out this line of code. <br>
      > When Mock is enabled, all SharePlay messages will go through the websocket. <br>
      > When Mock is disabled, all SharePlay messages will go through the official SharePlay.
      <div style="border: 1px solid red; padding: 10px; background-color: #f8d7da; color: #721c24; border-radius: 5px;">
        <strong>⚠️ Important:</strong> Comment out this line of code before publishing your app!! This line should only be added during testing.
      </div>
   3. Replace all the APIs below

   |GroupActivities|SharePlayMock|
   |---------------|-------------|
   |GroupActivity|GroupActivityMock|
   |GroupSession|GroupSessionMock|
   |GroupSessionMessenger|GroupSessionMessengerMock|
   |GroupStateObserver|GroupStateObserverMock|
   |Participant|ParticipantMock|
   |SystemCoordinator|SystemCoordinatorMock|
5. Test code
   1. Spin up websocket server
      Open a terminal and run
      ```
      java -jar /<your_path_to_the_jar_file>/shareplay-mock-server-0.1.0.jar
      ```
   2. Run your app on Simulator
   3. Connect your vision pro to Xcode and run your app on your vision pro.
      In Xcode, you can run 2 app instances at the same time on different targets.
   4. In your app, turn on SharePlay using the UI/feature you built for your app.
   5. The app on the simulator and the app on your device should now be connected and you can test and debug your code.

## Contact
[Spatial Devs Discord Server](https://discord.gg/GhHyZjwBYh)

[support@pixeland.tech](mailto:support@pixeland.tech)
      
   

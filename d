//
//  MainView.swift
//  OnlinePuzzles
//
//  Created by Leenah Albanna on 05/08/2022.
//  leenah.apps@gmail.com

import SwiftUI
import FirebaseAuth
import Firebase
import FirebaseDatabase
import GoogleMobileAds
import SDWebImageSwiftUI
import AVFoundation
import Foundation
import LinkPresentation
import UIKit

struct MainView: View {
    var categoryID = 0
    var levelID = 0
    var viewModel = ReadViewModel()
    let preferences = UserDefaults.standard
    @State var backClicked = false
    @State var value : Float = 0
    @State var listObject = [QuizObject]()
    @State var ref = Database.database().reference()
    @State var currentQuestionID = 1
    @State var currentLevelQuestionID = 1
    @State var totalCategory = 0
    @State var totalCategoryLevel = 0
    @State var totalAll = 0
    @State var showed_ad_question = 0
    
    @State var numberLevelQuestions = Int()
    @State var score = Int()
    @State var object = QuizObject()
    
    @State var isPlaying = false
    @StateObject private var soundManager = SoundManager()
    @State var randomAlphabet = (infoPlistValue(forKey: "alphabet") as?[String])!
    @State var answerArray =  [String]()
    @State var optionsArray =  [String]()
    @State var userAnswerArray = [String]()
    @State var answerSpaces = [String]()
    @State var userSelectedOptions = [String]()
    @State var currentLetter = 0
    @State private var timerSeconds: Float = 0.0
    @State private var levelProgress: Float = 0.0
    @State private var percentage: Float = 0.0
    
    @State var isShowAnswer = false
    @State var isSkipQuestion = false
    @State var isShowAd = false
    @State var isReplayLevel = false
    @State var isBackLevel = false
    @State var isRedirectLogin = false
    @State var isPlayClick = false
    @State var isAdWatched = false
    
    var rewardAd: RewardedAd
    @State private var showShareSheet = false
    @State  var capturedImage = UIImage()
    @State private var showWrongPopup = false
    @State private var showCorrectPopup = false
    @State private var showTimeoutPopup = false
    @State private var showSkipPopup = false
    @State private var showRevealPopup = false
    @State private var showAdsPopup = false
    @State private var showFinishedPopup = false
    @State private var showFailedPopup = false
    @State var isProgressActive = false
    @State var correctAnswer = ""
    @State var showNextQuestion = false
    @State private var layoutDirection = LayoutDirection.leftToRight
    @State var showingAlert = Bool()
    @State var audioPlayer: AVAudioPlayer?
    
    
    init(categoryID: Int, levelID: Int) {
        self.categoryID = categoryID
        self.levelID = levelID
        self.rewardAd = RewardedAd()
        
    }
    private var gridItemLayout = [GridItem(.adaptive(minimum: 32), alignment: .center)]
    private var gridItemLayout2 = [GridItem(.flexible(),spacing: 10)]
    
    var body: some View {
        if(isBackLevel == true){
            NavigationStack
            {
                LevelsView(categoryID: categoryID, categoryTitle: categoryTitle, levelID: 0)
            }
            
        } else if(isRedirectLogin == true){
            NavigationStack
            {
                ViewLoginUI()
            }
            
        }else{
            ZStack(){
                
                LinearGradient(colors: [Color("LightColor"), .white],startPoint: .top,endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack(){
                    
                    Divider().padding(.top, -25)
                    
                    ScrollView (.vertical, showsIndicators: false){
                        
                        if(object.q != nil){
                            Text(object.q!).font(.system(size: 20)).multilineTextAlignment(.center)
                                .foregroundColor(Color("AccentColor")).padding(.all,5)
                            
                        }
                        ZStack(){
                            if(object.i != nil){
                                if( UIDevice.isIPad == true){
                                    WebImage(url: URL(string: object.i!)).onSuccess { image, data, cacheType in
                                        // Success
                                        
                                    }.renderingMode(.original).resizable().scaledToFill()
                                        .frame(width: 550, height: 300).aspectRatio(contentMode: .fit)
                                        .cornerRadius(20).padding(.leading, 10).padding(.trailing, 10)
                                }else{
                                    WebImage(url: URL(string: object.i!)).onSuccess { image, data, cacheType in
                                        // Success
                                        
                                    }.renderingMode(.original).resizable().scaledToFill()
                                        .frame(width: UIScreen.main.bounds.width-20, height: 200).aspectRatio(contentMode: .fit)
                                        .cornerRadius(20).padding(.leading, 10).padding(.trailing, 10)
                                }
                          
                            }else{
                                Spacer(minLength: 50)

                            }
                            //===============//
                            if(object.s != nil){
                                
                                Button(action: {
                                    //Playsound
                                    soundManager.playSound(sound: object.s!)
                                    isPlaying.toggle()
                                    if isPlaying{
                                        soundManager.audioPlayer?.play()
                                    } else {
                                        soundManager.audioPlayer?.pause()
                                    }
                                    
                                }) {
                                    
                                    ZStack() {
                                        Image("speaker").resizable().frame(width: 24,height: 24).padding(.all,5)
                                    }.frame(width: 40,height: 40).background(Color.white).cornerRadius(20).opacity(0.8).overlay(
                                        Circle()
                                            .stroke(Color("AccentColor2"), lineWidth: 0.25)).padding(.top, 10)
                                }.padding(.top, 20).position(x: 35,y: 10)}
                            //===============//
                        }
                        
                        //======Answer letters list=====//
                        VStack(){
                            
                            var totalAnswerRows = Int(answerArray.count/8)
                            var splitedAnswerArray = answerArray.prefix(8)
                            Spacer(minLength: 10)

                            LazyHGrid(rows: gridItemLayout2, spacing: 10) {
                                if(object.a != nil){
                                    ForEach(Array(splitedAnswerArray.enumerated()), id: \.offset) { character in
                                        if(String(character.element) != " " ){
                                            
                                            Button(action: {
                                                if(userAnswerArray[character.offset] != ""){
                                                    currentLetter = character.offset
                                                    
                                                }
                                                if(userAnswerArray[character.offset] == "" && character.offset < userSelectedOptions.count){
                                                    currentLetter = character.offset
                                                }
                                                userAnswerArray[currentLetter] = ""
                                                userSelectedOptions[currentLetter] = ""
                                                isPlayClick = true
                                                
                                                
                                                
                                            }){
                                                Text(userAnswerArray[character.offset]).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 2)
                                            } .frame(width: 32, height: 32)
                                                .background(Color("AccentColor2"))
                                                .cornerRadius(5)
                                            
                                        }
                                        if(answerSpaces.contains(String(character.offset))){
                                            Button(action: {
                                            }){
                                                
                                            } .frame(width: 10, height: 32)
                                        }
                                        
                                        
                                        
                                    }
                                }
                            }        .environment(\.layoutDirection, layoutDirection)
                            
                            
                            ForEach(0..<totalAnswerRows, id: \.self) { currentRow in
                                var splitedAnswerArray = answerArray.suffix(answerArray.count - (8*(currentRow+1))).prefix(8)
                                
                                LazyHGrid(rows: gridItemLayout2, spacing: 10) {
                                    if(object.a != nil){
                                        ForEach(Array(splitedAnswerArray.enumerated()), id: \.offset) { character in
                                            if(String(character.element) != " " ){
                                                Button(action: {
                                                    if(userAnswerArray[character.offset] != ""){
                                                        currentLetter = character.offset+(8*(currentRow+1))}
                                                    if(userAnswerArray[character.offset] == "" && character.offset < userSelectedOptions.count){
                                                        currentLetter = character.offset+(8*(currentRow+1))
                                                    }
                                                    userAnswerArray[currentLetter] = ""
                                                    userSelectedOptions[currentLetter] = ""
                                                    isPlayClick = true
                                                }){
                                                    Text(userAnswerArray[character.offset+(8*(currentRow+1))]).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 2)
                                                } .frame(width: 32, height: 32)                            .background(Color("AccentColor2"))
                                                .cornerRadius(5)}
                                            
                                            if(answerSpaces.contains(String(Int(character.offset+(8*(currentRow+1)))))){
                                                Button(action: {
                                                }){
                                                    
                                                } .frame(width: 10, height: 32)
                                            }
                                            
                                            
                                        }
                                    }
                                }
                                
                            }  }.padding(5)
                        //==============================//
                        Spacer(minLength: 5)
                        //=========options buttons======//
                        HStack(){
                            
                            HStack(spacing: 0) {
                                Image("reveal").frame(width: 10,height: 10).padding(.all,5)
                                
                                Text((infoPlistValue(forKey: "showAnswerButton") as? String)!).font(.system(size: 12)).foregroundColor(Color("AccentColor2")).frame(width: 90,height: 40).onTapGesture {
                                    
                                    //
                                    if (preferences.object(forKey: "isPurchased") == nil) {
                                        showRevealPopup.toggle()
                                        
                                    }else{
                                        ShowAnswerMethod()
                                    }
                                    
                                    
                                }
                            }.frame(width: 130,height: 40).background(Color.white).cornerRadius(20).overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("AccentColor2"), lineWidth: 1)).padding(.top, 10)
                            
                            
                            
                            ZStack() {
                                Image("reset").resizable().frame(width: 24,height: 24).padding(.all,5).onTapGesture {
                                    userAnswerArray  = Array(repeating: "", count: answerArray.count)
                                    userSelectedOptions  = Array(repeating: "", count: answerArray.count)
                                    currentLetter = 0
                                }
                            }.frame(width: 40,height: 40).background(Color.white).cornerRadius(20).overlay(
                                Circle()
                                    .stroke(Color("AccentColor2"), lineWidth: 1)).padding(.top, 10)
                            
                            ZStack() {
                                Image("skip").resizable().frame(width: 24,height: 24).padding(.all,5).onTapGesture {
                                    if (score >= infoPlistValue(forKey: "skip_score") as! Int) {
                                        
                                        if (preferences.object(forKey: "isPurchased") == nil) {
                                            showSkipPopup.toggle()
                                            
                                        }else{
                                            SkipMethod()
                                        }
                                        
                                        
                                    }else{
                                        showingAlert = true
                                        isProgressActive = false
                                        
                                    }
                                    
                                    
                                } .alert(isPresented: $showingAlert) {
                                    Alert(title: Text((infoPlistValue(forKey: "skip_score_warning") as? String)!), message: Text(""), dismissButton: .default(Text((infoPlistValue(forKey: "okText") as? String)!)){
                                        showingAlert = false
                                        isProgressActive = true
                                        
                                    })
                                }
                                
                            }.frame(width: 40,height: 40).background(Color.white).cornerRadius(20).overlay(
                                Circle()
                                    .stroke(Color("AccentColor2"), lineWidth: 1)).padding(.top, 10)
                            
                            
                            HStack(spacing: 0) {
                                Text((infoPlistValue(forKey: "askFriendsButton") as? String)!).font(.system(size: 12)).foregroundColor(Color("AccentColor2")).frame(width: 90,height: 40)
                                Image("friends").frame(width: 10,height: 10).padding(.all,5)
                            }.frame(width: 130,height: 40).background(Color.white).cornerRadius(20).overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color("AccentColor2"), lineWidth: 1)).padding(.top, 10).onTapGesture {
                                        self.showShareSheet = true
                                        capturedImage = body.snapshot()
                                        
                                    }
                            
                            
                            
                        }
                        //==============================//
                        Spacer(minLength: 5)
                        
                        //======Choices letters list=====//
                        VStack(){
                            // number of rows
                            var totalOptionsRows = Int(optionsArray.count/8)
                            var splitedArray = optionsArray.prefix(8)
                            LazyHGrid(rows: gridItemLayout2, spacing: 10) {
                                if(object.a != nil){
                                    ForEach(Array(splitedArray.enumerated()), id: \.offset) { character in
                                        if(String(character.element) != " " ){
                                            if(userSelectedOptions.contains(String(Int(character.offset)))){
                                                
                                                Button(action: {
                                                    
                                                    
                                                }){
                                                    
                                                } .frame(width: 32, height: 32)
                                                
                                                    .cornerRadius(5)
                                                
                                            }else{
                                                Button(action: {
                                                    //add the selected optition
                                                    
                                                    userAnswerArray[currentLetter] = String(character.element).capitalized
                                                    userSelectedOptions[currentLetter] = String(character.offset)
                                                    if(currentLetter+1 < answerArray.count){                                                currentLetter = currentLetter+1}
                                                    isPlayClick = true
                                                }){
                                                    Text(String(character.element).capitalized).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 2)
                                                } .frame(width: 32, height: 32)
                                                    .background(Color("AccentColor"))
                                                    .cornerRadius(5)
                                                
                                            }
                                        }
                                        
                                    }
                                }
                            }
                            
                            ForEach(0..<totalOptionsRows, id: \.self) { currentRow in
                                var splitedArray = optionsArray.suffix(optionsArray.count - (8*(currentRow+1))).prefix(8)
                                
                                LazyHGrid(rows: gridItemLayout2, spacing: 10) {
                                    if(object.a != nil){
                                        ForEach(Array(splitedArray.enumerated()), id: \.offset) { character in
                                            if(String(character.element) != " " ){
                                                if(userSelectedOptions.contains(String(Int(character.offset+(8*(currentRow+1)))))){
                                                    
                                                    Button(action: {
                                                        
                                                    }){
                                                        
                                                    } .frame(width: 32, height: 32)
                                                    
                                                        .cornerRadius(5)
                                                    
                                                }else{
                                                    Button(action: {
                                                        userAnswerArray[currentLetter] = String(character.element).capitalized
                                                        userSelectedOptions[currentLetter] = String(Int(character.offset+(8*(currentRow+1))))
                                                        
                                                        if(currentLetter+1 < answerArray.count){
                                                            currentLetter = currentLetter+1}
                                                        isPlayClick = true
                                                    }){
                                                        Text(String(character.element).capitalized).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 2)
                                                    } .frame(width: 32, height: 32)
                                                        .background(Color("AccentColor"))
                                                        .cornerRadius(5)
                                                }
                                            }
                                            
                                        }
                                    }
                                }
                                
                            }
                        }.padding(5)
                   
                        
                        //==============================//
                        
                        
                    }
                    .padding(.top,-25)
                    .padding(.bottom, 5)
                    .padding(.leading, 15)
                    .padding(.trailing, 15)
                    
                    
                    Button(action: {
                        var userAnswerString = userAnswerArray.joined(separator: "")
                        
                        let isCorrect = userAnswerArray.elementsEqual(answerArray) { $0.lowercased() == $1.lowercased() }
                        if (isCorrect){
                            // correct
                            withAnimation {
                                currentQuestionID = currentQuestionID  + 1
                                currentLevelQuestionID = currentLevelQuestionID + 1
                                totalCategory = totalCategory + 1
                                totalCategoryLevel = totalCategoryLevel + 1
                                totalAll = totalAll + 1
                                preferences.set(currentQuestionID,forKey:"CurrentQuestion\(self.categoryID)")
                                preferences.set(currentLevelQuestionID,forKey:"currentLevelQuestion\(self.categoryID)_\(self.levelID)")
                                preferences.set(totalCategory,forKey:"total\(self.categoryID)")
                                preferences.set(totalCategoryLevel,forKey:"total\(self.categoryID)_\(self.levelID)")
                                preferences.set(totalAll,forKey:"total")
                                
                                showCorrectPopup.toggle()
                            }
                        }else{
                            // wrong
                            withAnimation {
                                showWrongPopup.toggle()
                                //reset
                                userAnswerArray  = Array(repeating: "", count: answerArray.count)
                                userSelectedOptions  = Array(repeating: "", count: answerArray.count)
                                currentLetter = 0
                                
                            }
                            if (score > 0) {
                                totalCategory = totalCategory - 1
                                totalCategoryLevel = totalCategoryLevel - 1
                                totalAll = totalAll - 1
                                
                                preferences.set(totalCategory ,forKey:"total\(self.categoryID)")
                                preferences.set(totalCategoryLevel ,forKey:"total\(self.categoryID)_\(self.levelID)")
                                preferences.set(totalAll,forKey:"total")
                                score = preferences.object(forKey: "total\(self.categoryID)_\(self.levelID)") as! Int
                            }
                            
                            
                            
                        }
                        //===update user data if registerd===//
                        guard let user =  Auth.auth().currentUser else { return }
                        if(user != nil){
                            if(user.displayName != nil){
                                var ref = Database.database().reference()
                                ref.child("Users/\(user.uid)/score").setValue(preferences.object(forKey: "total"))
                                ref.child("Users/\(user.uid)/data/\(categoryID)/total").setValue(preferences.object(forKey: "total\(categoryID)"))
                                ref.child("Users/\(user.uid)/data/\(categoryID)/CurrentQuestion").setValue(currentQuestionID)
                                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/currentLevelQuestion").setValue(currentLevelQuestionID)
                                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/total").setValue(preferences.object(forKey: "total\(categoryID)_\(levelID)"))
                                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/done").setValue(preferences.object(forKey: "done_\(categoryID)_\(levelID)"))
                            }
                        }
                        
                        
                        //===================================//
                    }){
                        Text((infoPlistValue(forKey: "submite") as? String)!).foregroundColor(.white).font(.system(size: 18).bold()).padding(.leading, 20).padding(.trailing, 20)
                    } .frame(width: 300, height: 32)
                        .background(Color("AccentColor2"))
                        .cornerRadius(25).padding(.leading, 20).padding(.trailing, 20).padding(.bottom, 10)
                    if( UIDevice.isIPad == true){
                        Spacer()}
                    if (preferences.object(forKey: "isPurchased") == nil) {
                        
                        GADBannerViewController()
                        .frame(width: GADAdSizeBanner.size.width, height: GADAdSizeBanner.size.height)}
                    
                }
                if showWrongPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    WrongPopup(showMe: $showWrongPopup, isProgressActive: $isProgressActive)
                }
                
                if showCorrectPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    CorrectPopup(showMe: $showCorrectPopup, isProgressActive: $isProgressActive, correctAnswer: $correctAnswer, showNextQuestion: $showNextQuestion)
                }
                
                if showTimeoutPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    TimeoutPopup(showMe: $showTimeoutPopup, isProgressActive: $isProgressActive, correctAnswer: $correctAnswer, showNextQuestion: $showNextQuestion)
                    
                }
                
                if showSkipPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    SkipPopup(showMe: $showSkipPopup, isProgressActive: $isProgressActive, showNextQuestion: $showNextQuestion, isSkipQuestion: $isSkipQuestion)
                    
                }
                if showRevealPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    RevealPopup(showMe: $showRevealPopup, isProgressActive: $isProgressActive, isShowAnswer: $isShowAnswer)
                    
                }
                
                if showAdsPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    AdsPopup(showMe: $showAdsPopup, isProgressActive: $isProgressActive, isShowAd: $isShowAd, levelProgress: $levelProgress)
                    
                }
                
                if showFinishedPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    FinishPopup(showMe: $showFinishedPopup, isProgressActive: $isProgressActive, isReplayLevel: $isReplayLevel, isBackLevel: $isBackLevel, isRedirectLogin: $isRedirectLogin, percentage: $percentage)
                    
                }
                
                if showFailedPopup {
                    LinearGradient(gradient: Gradient(colors: [Color.gray.opacity(0.01), Color.gray.opacity(0.5)]),
                                   startPoint: .top, endPoint: .bottom)
                    FailedPopup(showMe: $showFailedPopup, isProgressActive: $isProgressActive, isReplayLevel: $isReplayLevel, isBackLevel: $isBackLevel, percentage: $percentage)
                    
                }
                
                
                
            }.gesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local)
                .onEnded { value in
                    print(value.translation)
                    switch(value.translation.width, value.translation.height) {
                    case (...0, -30...30):  print("left swipe")
                        isBackLevel = true
                        
                    case (0..., -30...30):  print("right swipe")
                        isBackLevel = true
                        
                    case (-100...100, ...0):  print("up swipe")
                    case (-100...100, 0...):  print("down swipe")
                    default:  print("no clue")
                    }
                }
            )
            .sheet(isPresented: $showShareSheet, onDismiss: {
                self.showShareSheet = false
            }, content: {
                ShareSheet(activityItems: [capturedImage])
            })
            .onAppear(){
                if(self.isShowAnswer == true){
                    if(isAdWatched == true){
                        ShowAnswerMethod()}
                }
                else if(isSkipQuestion == true){
                    SkipMethod()
                }
                else{
                    RetriveData()
                    
                }
                
            }
            .onDisappear{
                isProgressActive = false
                if(isPlaying == true){
                    soundManager.audioPlayer?.pause()}
            }
            .onChange(of: showNextQuestion) { newValue in
                if(newValue == true){
                    RetriveData()
                }
                
            }.onChange(of: isSkipQuestion) { newValue in
                if(newValue == true){
                    if(self.rewardAd.rewardedAd != nil){
                        self.rewardAd.showAd(rewardFunction: {
                            isSkipQuestion = true
                        })
                    }else{
                        self.rewardAd.load()
                        
                    }
                }
                
            }.onChange(of: isShowAnswer) { newValue in
                if(newValue == true){
                    if(self.rewardAd.rewardedAd != nil){
                        self.rewardAd.showAd(rewardFunction: {
                            isAdWatched = true
                        })
                    }else{
                        self.rewardAd.load()
                        
                    }
                }
                
            }
            .onChange(of: isShowAd) { newValue in
                if(newValue == true){
                    if(self.rewardAd.rewardedAd != nil){
                        self.rewardAd.showAd(rewardFunction: {
                            isShowAd = true
                        })
                    }else{
                        self.rewardAd.load()
                        
                    }
                }
                
            } .onChange(of: isPlayClick) { newValue in
                if(newValue == true){
                    
                    PlayClickMethod()
                    
                }
                
            }.onChange(of: isReplayLevel) { newValue in
                if(newValue == true){
                    
                    ReplayMethod()
                    
                }
                
            }
            
            
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                isProgressActive = false
                
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                if(showTimeoutPopup == false && showSkipPopup == false && showWrongPopup == false  && showCorrectPopup == false && showRevealPopup == false && showAdsPopup == false  && showFinishedPopup == false && showFailedPopup == false && showingAlert == false && isShowAd == false  && isReplayLevel == false ){
                    
                    isProgressActive = true}
                
            }
            
            
            .navigationBarItems(leading:
                                    HStack {
                Text( "\(self.currentLevelQuestionID) / \(self.numberLevelQuestions)").font(.headline).foregroundColor(Color("AccentColor2")).frame(width: 80,height: 40).background(Color.white).cornerRadius(20.0).overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(.white, lineWidth: 5)).padding(.top, 20)
            }, trailing:
                                    HStack(spacing: 0) {
                
                Text("\(score)").font(.headline).foregroundColor(Color("AccentColor2")).frame(width: 50,height: 40)
                Image("score").frame(width: 10,height: 10).padding(.all,5)
            }.frame(width: 80,height: 40).background(Color.white).cornerRadius(20).overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white, lineWidth: 5)).padding(.top, 20)
            )
            .toolbar {
                ToolbarItem(placement: .principal) {            VStack(){
                    
                    Text( "\(categoryTitle) - \(levelID)").font(.headline).foregroundColor(Color("AccentColor")).padding(.top, 20)
                    if(timerSeconds > 0.0){
                        
                        ProgressView("", value: value, total: Float(timerSeconds))
                            .accentColor(.orange)
                            .scaleEffect(x:1, y:3, anchor: .center)
                            .onAppear {
                                // 2
                                let player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "tick", ofType: "mp3")!))
                                
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                                    if(isProgressActive == true ){
                                        self.value += 1
                                        
                                        //=======check the last 5 seconds=======//
                                        
                                        if(Float(self.value) == Float(timerSeconds)-5){
                                            if (preferences.object(forKey: "disableSounds") == nil) {
                                                player.play()
                                                
                                            }
                                            
                                        }
                                        //=======================================//
                                        
                                        //=======================show the Timeout popup when finished=====================//
                                        if(self.value == Float(timerSeconds)){
                                            
                                            showTimeoutPopup.toggle()
                                            currentQuestionID = currentQuestionID  + 1
                                            currentLevelQuestionID = currentLevelQuestionID + 1
                                            
                                            preferences.set(currentQuestionID,forKey:"CurrentQuestion\(self.categoryID)")
                                            preferences.set(currentLevelQuestionID,forKey:"currentLevelQuestion\(self.categoryID)_\(self.levelID)")
                                            
                                            if (score > 0) {
                                                totalCategory = totalCategory - 1
                                                totalCategoryLevel = totalCategoryLevel - 1
                                                totalAll = totalAll - 1
                                                
                                                preferences.set(totalCategory,forKey:"total\(self.categoryID)")
                                                preferences.set(totalCategoryLevel,forKey:"total\(self.categoryID)_\(self.levelID)")
                                                preferences.set(totalAll,forKey:"total")
                                                score = preferences.object(forKey: "total\(self.categoryID)_\(self.levelID)") as! Int
                                            }
                                            //===update user data if registerd===//
                                            guard let user =  Auth.auth().currentUser else { return }
                                            if(user != nil){
                                                if(user.displayName != nil){
                                                    var ref = Database.database().reference()
                                                    ref.child("Users/\(user.uid)/score").setValue(preferences.object(forKey: "total"))
                                                    ref.child("Users/\(user.uid)/data/\(categoryID)/total").setValue(preferences.object(forKey: "total\(categoryID)"))
                                                    ref.child("Users/\(user.uid)/data/\(categoryID)/CurrentQuestion").setValue(currentQuestionID)
                                                    ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/currentLevelQuestion").setValue(currentLevelQuestionID)
                                                    ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/total").setValue(preferences.object(forKey: "total\(categoryID)_\(levelID)"))
                                                    ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/done").setValue(preferences.object(forKey: "done_\(categoryID)_\(levelID)"))
                                                }
                                            }
                                            
                                            //===================================//
                                            //================================================================================//
                                        }
                                        
                                    }
                                    
                                }
                            }.ignoresSafeArea().frame(width: 150,height: 3).padding(.top, -30)
                    }
                    
                }
                    
                    
                }
                
                
            }
        }
        
        
    }
    
    func RetriveData(){
        isPlaying = false
        showNextQuestion = false
        value = 0

        if(preferences.object(forKey: "CurrentQuestion\(self.categoryID)") != nil){
            currentQuestionID = preferences.object(forKey: "CurrentQuestion\(self.categoryID)") as! Int
        }
        if(preferences.object(forKey: "currentLevelQuestion\(self.categoryID)_\(self.levelID)") != nil){
            currentLevelQuestionID = preferences.object(forKey: "currentLevelQuestion\(self.categoryID)_\(self.levelID)")  as! Int
            
        }
        
        if(preferences.object(forKey: "total\(self.categoryID)_\(self.levelID)") != nil){
            score = preferences.object(forKey: "total\(self.categoryID)_\(self.levelID)") as! Int
            totalCategoryLevel = preferences.object(forKey: "total\(self.categoryID)_\(self.levelID)") as! Int
            
        }else{
            score = 0
        }
        if(preferences.object(forKey: "total\(self.categoryID)") != nil){
            totalCategory = preferences.object(forKey:"total\(self.categoryID)") as! Int
            
            
        }
        if(preferences.object(forKey: "total") != nil){
            totalAll = preferences.object(forKey:"total") as! Int
        }
        answerSpaces = [String]()
        ref.child("data").child("\(self.categoryID)").child("\(self.levelID)").observe(.value){
            snapshot in
            if(snapshot.exists()){
                
                self.numberLevelQuestions = Int(snapshot.childrenCount)
                if(currentLevelQuestionID <=  self.numberLevelQuestions){
                    syncRemoteConfig()
                    
                    ref.child("data").child("\(self.categoryID)").child("\(self.levelID)").child("\(self.currentLevelQuestionID)")
                        .observeSingleEvent(of: .value, with: {
                            snapshot in
                            
                            if(snapshot.exists()){
                                object = try! snapshot.data(as: QuizObject.self)
                                self.randomAlphabet.shuffle()
                                
                                
                                if(object.s != nil){
                                    //Playsound
                                    soundManager.playSound(sound: object.s!)
                                    isPlaying.toggle()
                                    if isPlaying{
                                        soundManager.audioPlayer?.play()
                                    } else {
                                        soundManager.audioPlayer?.pause()
                                    }}
                                
                                if(object.a != nil){
                                    correctAnswer = object.a!
                                    answerArray = Array(object.a!).map { String($0) }
                                    
                                    for (index, element) in answerArray.enumerated() {
                                        if(element == " "){
                                            //enable for ltr
                                            answerSpaces.append(String(index-1))
                                            //enable for rtl
                                            //answerSpaces.append(String(index))
                                           
                                        }
                                        
                                    }
                                    answerArray.removeAll(where: { [" "].contains($0) })
                                    
                                    optionsArray = answerArray.map { String($0) } + Array(randomAlphabet.prefix(answerArray.count)).map { String($0) }
                                    optionsArray.shuffle()
                                }
                                
                                
                                userAnswerArray  = Array(repeating: "", count: answerArray.count)
                                userSelectedOptions  = Array(repeating: "", count: answerArray.count)
                                currentLetter = 0
                                
                            }
                            
                        }
                                            
                        )
                    if((currentLevelQuestionID % (infoPlistValue(forKey: "adsCounter") as! Int) == 0) && currentLevelQuestionID > ((infoPlistValue(forKey: "adsCounter") as! Int) - 1) ){
                        if (currentLevelQuestionID < numberLevelQuestions) {
                            if (showed_ad_question < currentLevelQuestionID) {
                                showed_ad_question = currentLevelQuestionID
                                levelProgress = (Float(currentLevelQuestionID)/Float(numberLevelQuestions))*100
                                
                                showAdsPopup.toggle()
                                isProgressActive = false
                                
                            }}
                    }
                    
                }else{
                    currentLevelQuestionID = currentLevelQuestionID - 1
                    
                    percentage = Float((Float(score) /  Float(self.numberLevelQuestions)) * 100)
                    
                    if (percentage >= Float(infoPlistValue(forKey: "pass_average") as! Int)) {
                        preferences.set("yes", forKey: "done_\(categoryID)_\(levelID)")
                        showFinishedPopup.toggle()
                        //===Upload user data if registerd===//
                        guard let user =  Auth.auth().currentUser else { return }
                        if(user != nil){
                            if(user.displayName != nil){
                                var ref = Database.database().reference()
                                ref.child("Users/\(user.uid)/score").setValue(preferences.object(forKey: "total"))
                                ref.child("Users/\(user.uid)/name").setValue(user.displayName as! String)
                                ref.child("Users/\(user.uid)/image").setValue(user.photoURL!.absoluteString)
                            }
                        }
                        //===================================//
                    } else {
                        showFailedPopup.toggle()
                    }
                    
                }
                
            }
        }
        
        
        
    }
    
    func ShowAnswerMethod(){
        isShowAnswer = false
        isAdWatched = false
        self.rewardAd.load()
        
        userAnswerArray  = Array(repeating: "", count: answerArray.count)
        userSelectedOptions  = Array(repeating: "", count: answerArray.count)
        currentLetter = 0
        for (answerIndex, answerElement) in answerArray.enumerated() {
            for (optionIndex, optionElement) in optionsArray.enumerated() {
                if(optionElement == answerArray[answerIndex]){
                    userAnswerArray[answerIndex] = String(answerElement).capitalized
                    userSelectedOptions[answerIndex] = String(optionIndex)
                    if(currentLetter+1 < answerArray.count){
                        currentLetter = currentLetter+1}
                }
            }
        }
        
    }
    
    func SkipMethod(){
        isSkipQuestion = false
        
        showNextQuestion = true
        
        currentQuestionID = currentQuestionID  + 1
        currentLevelQuestionID = currentLevelQuestionID + 1
        
        preferences.set(currentQuestionID,forKey:"CurrentQuestion\(self.categoryID)")
        preferences.set(currentLevelQuestionID,forKey:"currentLevelQuestion\(self.categoryID)_\(self.levelID)")
        
        if (score > 0) {
            
            totalCategory = totalCategory - (infoPlistValue(forKey: "skip_score") as? Int)!
            totalCategoryLevel = totalCategoryLevel - (infoPlistValue(forKey: "skip_score") as? Int)!
            totalAll = totalAll - (infoPlistValue(forKey: "skip_score") as? Int)!
            
            
            preferences.set(totalCategory ,forKey:"total\(self.categoryID)")
            preferences.set(totalCategoryLevel ,forKey:"total\(self.categoryID)_\(self.levelID)")
            preferences.set(totalAll ,forKey:"total")
            score = preferences.object(forKey: "total\(self.categoryID)_\(self.levelID)") as! Int
        }
        //===update user data if registerd===//
        guard let user =  Auth.auth().currentUser else { return }
        if(user != nil){
            if(user.displayName != nil){
                var ref = Database.database().reference()
                ref.child("Users/\(user.uid)/score").setValue(preferences.object(forKey: "total"))
                ref.child("Users/\(user.uid)/data/\(categoryID)/total").setValue(preferences.object(forKey: "total\(categoryID)"))
                ref.child("Users/\(user.uid)/data/\(categoryID)/CurrentQuestion").setValue(currentQuestionID)
                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/currentLevelQuestion").setValue(currentLevelQuestionID)
                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/total").setValue(preferences.object(forKey: "total\(categoryID)_\(levelID)"))
                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/done").setValue(preferences.object(forKey: "done_\(categoryID)_\(levelID)"))
            }
        }
        //===================================//
    }
    
    
    fileprivate func syncRemoteConfig() {
        let remoteConfig = RemoteConfig.remoteConfig()
        
#if DEBUG
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 1
        remoteConfig.configSettings = settings
#endif
        
        remoteConfig.fetchAndActivate { (status, error) in
            
            var stringTimer = remoteConfig.configValue(forKey: "timer").stringValue ?? ""
            if let convertedNumber = Float(stringTimer) {
                timerSeconds = convertedNumber
                isProgressActive = true
            }
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            //status always prints status.successUsingPreFetchedData
        }
    }
    
    func PlayClickMethod(){
        //===============================//
        guard let url = Bundle.main.url(forResource: "click", withExtension: ".wav") else {return}
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            if (preferences.object(forKey: "disableSounds") == nil) {
                audioPlayer?.play()
                isPlayClick = false
                
            }
        } catch {
            print("Error playing audio file: \(error.localizedDescription)")
        }
        //===============================//
    }
    
    func ReplayMethod(){
        isReplayLevel = false
        currentLevelQuestionID = 1;
        currentQuestionID = 1;
        
        if((preferences.object(forKey:"CurrentQuestion\(self.categoryID)") as! Int - numberLevelQuestions) >= 0 ){
            preferences.set((preferences.object(forKey:"CurrentQuestion\(self.categoryID)") as! Int - numberLevelQuestions),forKey:"CurrentQuestion\(self.categoryID)")
        }
        if(preferences.object(forKey:"total\(self.categoryID)") != nil){
            if((preferences.object(forKey:"total\(self.categoryID)") as! Int - numberLevelQuestions) >= 0 ){
                preferences.set((preferences.object(forKey:"total\(self.categoryID)") as! Int - numberLevelQuestions),forKey:"total\(self.categoryID)")
                preferences.set((preferences.object(forKey:"total") as! Int - numberLevelQuestions),forKey:"total")
            }
            
        }
        preferences.set(1,forKey:"currentLevelQuestion\(self.categoryID)_\(self.levelID)")
        preferences.set(0,forKey:"total\(self.categoryID)_\(self.levelID)")
        //===update user data if registerd===//
        guard let user =  Auth.auth().currentUser else {  RetriveData()
            return
        }
        if(user != nil){
            if(user.displayName != nil){
                var ref = Database.database().reference()
                ref.child("Users/\(user.uid)/score").setValue(preferences.object(forKey: "total"))
                ref.child("Users/\(user.uid)/data/\(categoryID)/total").setValue(preferences.object(forKey: "total\(categoryID)"))
                ref.child("Users/\(user.uid)/data/\(categoryID)/CurrentQuestion").setValue(currentQuestionID)
                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/currentLevelQuestion").setValue(currentLevelQuestionID)
                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/total").setValue(preferences.object(forKey: "total\(categoryID)_\(levelID)"))
                ref.child("Users/\(user.uid)/data/\(categoryID)/\(levelID)/done").setValue(preferences.object(forKey: "done_\(categoryID)_\(levelID)"))
                
                RetriveData()
                
            }
        }else{
           
        }
        
        //===================================//
        
    }
    
}

struct MainView_Previews: PreviewProvider {
    @State static var levelID: Int = 0
    
    static var previews: some View {
        MainView(categoryID: 0, levelID: levelID)
    }
}
class SoundManager : ObservableObject {
    var audioPlayer: AVPlayer?
    
    func playSound(sound: String){
        if let url = URL(string: sound) {
            self.audioPlayer = AVPlayer(url: url)
        }
    }
}



final class RewardedAd {
    private let rewardId = "\((infoPlistValue(forKey: "RewardedVideoAdId") as? String)!)"
    
    var rewardedAd: GADRewardedAd?
    
    init() {
        load()
    }
    
    func load(){
        let request = GADRequest()
        request.scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene

        // add extras here to the request, for example, for not presonalized Ads
        GADRewardedAd.load(withAdUnitID: rewardId, request: request, completionHandler: {rewardedAd, error in
            if error != nil {
                // loading the rewarded Ad failed :(
                return
            }
            self.rewardedAd = rewardedAd
        })
    }
    
    func showAd(rewardFunction: @escaping () -> Void) -> Bool {
        guard let rewardedAd = rewardedAd else {
            return false
        }
        
        guard let root = UIApplication.shared.keyWindowPresentedController else {
            return false
        }
        rewardedAd.present(fromRootViewController: root, userDidEarnRewardHandler: rewardFunction)
        return true
    }
}

// just an extension to make our life easier to receive the root view controller [Rewarded ads usage]
extension UIApplication {
    
    var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .first(where: { $0 is UIWindowScene })
            .flatMap({ $0 as? UIWindowScene })?.windows
            .first(where: \.isKeyWindow)
    }
    
    var keyWindowPresentedController: UIViewController? {
        var viewController = self.keyWindow?.rootViewController
        
        if let presentedController = viewController as? UITabBarController {
            viewController = presentedController.selectedViewController
        }
        
        while let presentedController = viewController?.presentedViewController {
            if let presentedController = presentedController as? UITabBarController {
                viewController = presentedController.selectedViewController
            } else {
                viewController = presentedController
            }
        }
        return viewController
    }
}


extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        // No update needed
    }
}
//======================================//
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareSheet>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ShareSheet>) {}
}
//======================================//
struct WrongPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @State private var startAnimation = false
    @State var audioPlayer: AVAudioPlayer?
    let preferences = UserDefaults.standard
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    
                    Text((infoPlistValue(forKey: "tryAgain") as? String)!).onTapGesture {
                        
                        showMe.toggle()
                        isProgressActive = true
                        
                    }.foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                    
                        .background(Color("AccentColor"))
                        .cornerRadius(25).padding(.leading, 20).padding(.trailing, 20)
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 200,height: 140, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("wrong").resizable().frame(width: 80,height: 80).padding(.top, -100)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    //===============================//
                    guard let url = Bundle.main.url(forResource: "wrong", withExtension: ".mp3") else {return}
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        if (preferences.object(forKey: "disableSounds") == nil) {
                            audioPlayer?.play()
                        }
                    } catch {
                        print("Error playing audio file: \(error.localizedDescription)")
                    }
                    //===============================//
                    
                    
                    
                    
                    
                }
                
        }
        
    }
}
struct CorrectPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var correctAnswer: String
    @Binding var showNextQuestion: Bool
    @State private var startAnimation = false
    @State var audioPlayer: AVAudioPlayer?
    let preferences = UserDefaults.standard
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    Text((infoPlistValue(forKey: "perfect") as? String)!).foregroundColor(Color("AccentColor2")).font(.system(size: 20).bold())
                    Text(correctAnswer).foregroundColor(.green).font(.system(size: 25).bold()).padding(20)
                    Text((infoPlistValue(forKey: "continueButton") as? String)!).onTapGesture {
                        
                        showMe.toggle()
                        showNextQuestion = true
                        
                    }.foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                    
                        .background(Color("AccentColor2"))
                        .cornerRadius(25).padding(.leading, 20).padding(.trailing, 20)
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 300,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("correct").resizable().frame(width: 80,height: 80).padding(.top, -160)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    //===============================//
                    guard let url = Bundle.main.url(forResource: "correct", withExtension: ".mp3") else {return}
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        if (preferences.object(forKey: "disableSounds") == nil){
                            audioPlayer?.play()}
                    } catch {
                        print("Error playing audio file: \(error.localizedDescription)")
                    }
                    //===============================//
                    
                }
        }
        
    }
}
struct TimeoutPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var correctAnswer: String
    @Binding var showNextQuestion: Bool
    @State private var startAnimation = false
    @State var audioPlayer: AVAudioPlayer?
    let preferences = UserDefaults.standard
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    Text((infoPlistValue(forKey: "timeout") as? String)!).foregroundColor(Color("AccentColor2")).font(.system(size: 25).bold())
                    Text(correctAnswer).foregroundColor(.green).font(.system(size: 25).bold()).padding(20)
                    Text((infoPlistValue(forKey: "continueButton") as? String)!).onTapGesture {
                        
                        showMe.toggle()
                        showNextQuestion = true
                        
                    }.foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                    
                        .background(Color("AccentColor2"))
                        .cornerRadius(25).padding(.leading, 20).padding(.trailing, 20)
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 280,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("timeout").resizable().frame(width: 80,height: 80)
                .rotationEffect(Angle(degrees: startAnimation ? 45.0 : 0.0))
            
                .animation(  Animation.linear(duration: 0.5)
                    .repeatForever(autoreverses: true))
                .padding(.top, -160)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    //===============================//
                    guard let url = Bundle.main.url(forResource: "timeout", withExtension: ".mp3") else {return}
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        if (preferences.object(forKey: "disableSounds") == nil) {
                            audioPlayer?.play()}
                    } catch {
                        print("Error playing audio file: \(error.localizedDescription)")
                    }
                    //===============================//
                    
                }
        }
        
    }
}
struct SkipPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var showNextQuestion: Bool
    @Binding var isSkipQuestion: Bool
    @State private var startAnimation = false
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    Text((infoPlistValue(forKey: "skipText") as? String)!).padding(.top, -80).multilineTextAlignment(.center)
                        .foregroundColor(Color("AccentColor")).font(.system(size: 20).bold())
                    HStack(){
                        Text((infoPlistValue(forKey: "continueButton") as? String)!).onTapGesture {
                            showMe.toggle()
                            
                            isSkipQuestion = true
                            
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor2"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                        
                        Text((infoPlistValue(forKey: "backButton") as? String)!).onTapGesture {
                            isProgressActive = true
                            
                            showMe.toggle()
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                    }
                    
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 280,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("ad").resizable().frame(width: 80,height: 80)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
            
                .padding(.top, -160)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    
                    
                }
        }
        
    }
}
struct RevealPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var isShowAnswer: Bool
    @State private var startAnimation = false
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    Text((infoPlistValue(forKey: "reavealAnswer") as? String)!).padding(.top, -80).multilineTextAlignment(.center)
                        .foregroundColor(Color("AccentColor")).font(.system(size: 20).bold())
                    HStack(){
                        Text((infoPlistValue(forKey: "continueButton") as? String)!).onTapGesture {
                            showMe.toggle()
                            
                            isShowAnswer = true
                            
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor2"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                        
                        Text((infoPlistValue(forKey: "backButton") as? String)!).onTapGesture {
                            isProgressActive = true
                            
                            showMe.toggle()
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                    }
                    
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 280,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("ad").resizable().frame(width: 80,height: 80)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
            
                .padding(.top, -160)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    
                    
                }
        }
        
    }
}
struct AdsPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var isShowAd: Bool
    @Binding var levelProgress: Float
    @State private var startAnimation = false
    @State var audioPlayer: AVAudioPlayer?
    let preferences = UserDefaults.standard
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    
                    Text("\((infoPlistValue(forKey: "adsText1") as? String)!) \(Int(levelProgress))%\n\((infoPlistValue(forKey: "adsText2") as? String)!)").padding(.top, -90).padding(.horizontal,10).multilineTextAlignment(.center)
                        .foregroundColor(Color("AccentColor")).font(.system(size: 20).bold())
                    HStack(){
                        Text((infoPlistValue(forKey: "continueButton") as? String)!).onTapGesture {
                            showMe.toggle()
                            
                            isShowAd = true
                            
                            
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor2"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                        
                        Text((infoPlistValue(forKey: "backButton") as? String)!).onTapGesture {
                            isProgressActive = true
                            
                            showMe.toggle()
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                    }
                    
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 280,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("rest").resizable().frame(width: 80,height: 80)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
            
                .padding(.top, -160)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    //===============================//
                    guard let url = Bundle.main.url(forResource: "ads", withExtension: ".mp3") else {return}
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        if (preferences.object(forKey: "disableSounds") == nil) {
                            audioPlayer?.play()}
                    } catch {
                        print("Error playing audio file: \(error.localizedDescription)")
                    }
                    //===============================//
                    
                }
        }
        
    }
}
struct FinishPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var isReplayLevel: Bool
    @Binding var isBackLevel: Bool
    @Binding var isRedirectLogin: Bool
    @Binding var percentage: Float
    @State private var startAnimation = false
    @State var audioPlayer: AVAudioPlayer?
    @State private var isLoggedin = false
    let preferences = UserDefaults.standard
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    
                    Text("\((infoPlistValue(forKey: "congratulation") as? String)!)\n\((infoPlistValue(forKey: "finishLevelText1") as? String)!)\n\((infoPlistValue(forKey: "finishLevelText2") as? String)!) \(percentage, specifier: "%.2f")%").padding(.top, -90).padding(.horizontal,10).multilineTextAlignment(.center)
                        .foregroundColor(Color("AccentColor")).font(.system(size: 20).bold())
                    
                    if(isLoggedin == false){
                        Text("\((infoPlistValue(forKey: "loginText") as? String)!)").padding(.horizontal,10).multilineTextAlignment(.center)
                            .foregroundColor(.blue).font(.system(size: 16).bold()).underline(true, color: .blue).onTapGesture {
                                //Redirect to the login UI
                                isRedirectLogin = true
                            }
                    }
                    HStack(){
                        Text((infoPlistValue(forKey: "replayButton") as? String)!).onTapGesture {
                            
                            
                            showMe.toggle()
                            isReplayLevel = true
                            
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor2"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                        
                        Text((infoPlistValue(forKey: "backButton") as? String)!).onTapGesture {
                            
                            showMe.toggle()
                            isBackLevel = true
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                    }
                    
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 280,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("endlevel").resizable().frame(width: 80,height: 80)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
            
                .padding(.top, -160)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    //===============================//
                    guard let url = Bundle.main.url(forResource: "finish", withExtension: ".mp3") else {return}
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        if (preferences.object(forKey: "disableSounds") == nil) {
                            audioPlayer?.play()
                        }
                    } catch {
                        print("Error playing audio file: \(error.localizedDescription)")
                    }
                    //===============================//
                    
                    guard let user =  Auth.auth().currentUser else { return }
                    if(user != nil){
                        if(user.displayName != nil){
                            isLoggedin = true
                        }}
                    
                }
        }
        
    }
}

struct FailedPopup: View {
    
    @Binding var showMe: Bool
    @Binding var isProgressActive: Bool
    @Binding var isReplayLevel: Bool
    @Binding var isBackLevel: Bool
    @Binding var percentage: Float
    @State private var startAnimation = false
    @State var audioPlayer: AVAudioPlayer?
    let preferences = UserDefaults.standard
    
    
    var body: some View {
        ZStack {
            ZStack{
                
                VStack () {
                    
                    Text("\((infoPlistValue(forKey: "levelFailed") as? String)!)").padding(.top, -90).padding(.horizontal,10).multilineTextAlignment(.center)
                        .foregroundColor(Color("AccentColor")).font(.system(size: 20).bold())
                    Text("\((infoPlistValue(forKey: "levelFailedText") as? String)!)\n\(percentage, specifier: "%.2f")%").padding(.top, -60).padding(.horizontal,10).multilineTextAlignment(.center)
                        .foregroundColor(Color("GrayDark")).font(.system(size: 20).bold())
                    HStack(){
                        Text((infoPlistValue(forKey: "replayButton") as? String)!).onTapGesture {
                            
                            
                            showMe.toggle()
                            isReplayLevel = true
                            
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor2"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                        
                        Text((infoPlistValue(forKey: "backButton") as? String)!).onTapGesture {
                            
                            showMe.toggle()
                            isBackLevel = true
                            
                            
                        }.frame(width:90).foregroundColor(.white).font(.system(size: 20).bold()).padding(.all, 15)
                        
                            .background(Color("AccentColor"))
                            .cornerRadius(25).padding(.leading, 2).padding(.trailing, 2)
                    }
                    
                    
                    
                    
                }
                
            }.padding(.bottom, 10).frame(width: 280,height: 250, alignment: .bottom).background(Color.white).cornerRadius(20)
            Image("wrong").resizable().frame(width: 80,height: 80)
                .scaleEffect(startAnimation ? 1 : 1.1)
                .animation(startAnimation ? Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true): Animation.default)
            
                .padding(.top, -160)
                .onAppear{
                    startAnimation = true
                    isProgressActive = false
                    //===============================//
                    guard let url = Bundle.main.url(forResource: "wrong", withExtension: ".mp3") else {return}
                    do {
                        audioPlayer = try AVAudioPlayer(contentsOf: url)
                        if (preferences.object(forKey: "disableSounds") == nil) {
                            audioPlayer?.play()
                        }
                    } catch {
                        print("Error playing audio file: \(error.localizedDescription)")
                    }
                    //===============================//
                    
                }
        }
        
    }
}
extension View {
    func swipe(
        up: @escaping (() -> Void) = {},
        down: @escaping (() -> Void) = {},
        left: @escaping (() -> Void) = {},
        right: @escaping (() -> Void) = {}
    ) -> some View {
        return self.gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onEnded({ value in
                if value.translation.width < 0 { left() }
                if value.translation.width > 0 { right() }
                if value.translation.height < 0 { up() }
                if value.translation.height > 0 { down() }
            }))
    }
}
extension UIDevice {
    static var isIPad: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var isIPhone: Bool {
        UIDevice.current.userInterfaceIdiom == .phone
    }
}

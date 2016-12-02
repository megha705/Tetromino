//
//  GameViewController.swift
//  TetrominoTouch
//
//  Created by Christopher Reitz on 02/11/2016.
//  Copyright © 2016 Christopher Reitz. All rights reserved.
//

import UIKit

final class GameViewController: UIViewController {

    // MARK: - Properties

    let game: Game
    let userInput: TouchUserInput
    let highscore: Highscore
    let scoreView: ScoreView
    let levelView: LevelView
    let nextPieceView: NextPieceView
    let gameOverView: GameOverView

    var musicPlayer = MusicPlayer(music: .techno)
    var timer: Timer?

    // MARK: - Initializers

    init(game: Game, userInput: TouchUserInput, highscore: Highscore) {
        self.game = game
        self.highscore = highscore
        self.userInput = userInput
        self.scoreView = ScoreView(score: game.score, highscore: highscore)
        self.levelView = LevelView()
        self.nextPieceView = NextPieceView(piece: game.nextPiece)
        self.gameOverView = GameOverView()

        super.init(nibName: nil, bundle: nil)
        game.delegate = self
        userInput.delegate = game
        userInput.view = view
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) is not supported")
    }

    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        configureAppearance()
        configureNavigationBar()
        configureGameOverView()
//        musicPlayer.play()

        newGame()
    }

    private func configureAppearance() {
        view.backgroundColor = .white
    }

    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: levelView)
        navigationItem.titleView = scoreView
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: nextPieceView)
    }

    private func configureGameOverView() {
        view.addSubview(gameOverView)
        let views =  ["gameOverView": gameOverView]
        addConstraints(format: "V:|[gameOverView]|", views: views)
        addConstraints(format: "H:|[gameOverView]|", views: views)

        gameOverView.newGameButton.addTarget(self, action: #selector(newGame), for: .touchUpInside)
    }

    // MARK: - Interval

    func disableInterval() {
        timer?.invalidate()
    }

    func newInterval(level: Level) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(
            timeInterval: level.speed,
            target: self,
            selector: #selector(interval),
            userInfo: nil,
            repeats: true
        )
    }

    func interval() {
        game.tick()
    }

    func newGame() {
        game.new()
        levelChanged(to: game.level)
        scoreView.score = game.score
        scoreView.highscore = highscore
        gameOverView.isHidden = true
    }
}

// MARK: - GameDelegate

extension GameViewController: GameDelegate {
    func gameOver() {
        disableInterval()
        gameOverView.newHighScore = highscore.save(value: game.score.value)
        view.bringSubview(toFront: gameOverView)
        gameOverView.isHidden = false
    }

    func display(piece: Piece) {
        for square in piece.squares {
            view.addSubview(square)
        }
    }

    func remove(piece: Piece) {
        for square in piece.squares {
            square.removeFromSuperview()
        }
    }

    func next(piece nextPiece: Piece) {
        nextPieceView.piece = nextPiece
    }

    func scoreDidUpdate(newScore: Score) {
        scoreView.score = newScore
    }

    func levelChanged(to newLevel: Level) {
        newInterval(level: newLevel)
        levelView.level = newLevel
    }
}
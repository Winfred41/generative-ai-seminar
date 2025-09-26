import random as rand;

node round {
    has player_choice: str;
    has computer_choice: str;
    has result: str;
}

walker RPSGame {
    has score: int = 0;
    has rounds: int = 3;
    has results: list = [];

    can start with `root entry {
        for i=0 to i<self.rounds by i+=1 {
            let choices = ["rock", "paper", "scissors"];
            let comp_choice = choices[rand.randint(0, 2)];

            # fix: grab the node, not the list
            let r = (root ++> round("", comp_choice, ""))[0];
            self.results.append(r);
        }
        disengage;
    }

    def play_round(entry: round, player_choice: str) {
        entry.player_choice = player_choice;

        if entry.player_choice == entry.computer_choice {
            entry.result = "draw";
        } elif (entry.player_choice == "rock" and entry.computer_choice == "scissors") or
                 (entry.player_choice == "paper" and entry.computer_choice == "rock") or
                 (entry.player_choice == "scissors" and entry.computer_choice == "paper") {
            entry.result = "win";
            self.score += 1;
        } else {
            entry.result = "lose";
        }
    }

    can summary with `root entry {
        print("Final Score: " + str(self.score) + "/" + str(self.rounds));
        for r in self.results {
            print("You: " + str(r.player_choice) +
                  " | Computer: " + str(r.computer_choice) +
                  " => " + str(r.result));
        }
    }
}

with entry:__main__ {
    let root_node = root;
    let game = RPSGame();
    game.start(root_node);

    print("Welcome to Rock-Paper-Scissors!");
    for i in range(game.rounds) {
        let choice = input("Round " + str(i+1) + " - choose rock/paper/scissors: ");
        game.play_round(game.results[i], choice);
    }

    game.summary(root_node);
}

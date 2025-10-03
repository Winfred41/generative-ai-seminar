import random as random;
import from byllm.llm { Model }

# Globals: Initialize the LLM (Gemini is used here)
glob llm = Model(model_name="gemini/gemini-2.0-flash", verbose=False);

# LLM Function: The LLM will predict the computer's choice based on the game history.
def get_llm_choice(history_string: str) -> str by llm(
    system_prompt="You are an expert at Rock-Paper-Scissors strategy. Based on the provided history of the human player's choices, your task is to choose the best next move ('rock', 'paper', or 'scissors') that is most likely to win. Only output the choice, nothing else."
);

# --- Nodes ---
node round {
    has player_choice: str;
    has computer_choice: str;
    has result: str;
}

# --- Walker ---
walker RPSGame {
    has score: int = 0;
    has rounds: int = 5;
    has current_round_num: int = 0;
    has results: list = [];
    has history: str = "";
    has get_winning_choice: list[str] = ["rock", "paper", "scissors"];

    # Setup the game: starts the first round
    can start with root entry {
        print("--- LLM-Powered Rock-Paper-Scissors ---");
        print("Playing a game of " + str(rounds) + " rounds.");

        # Determine the computer's first random move
        let comp_choice = get_winning_choice[random.randint(0, 2)];
        
        # Create the first round node and move to it
        let next_node = spawn here ++> round(
            player_choice="",
            computer_choice=comp_choice,
            result=""
        );
        self.results.append(next_node);
        self.current_round_num = 1;

        visit -> next_node;
    }

    # Main game logic: user input and comparison happen here
    can play_round with round entry {
        # 1. Prompt the user for input
        let choice = input("Round " + str(current_round_num) + " - choose (rock/paper/scissors): ");

        # Set the player's choice on the current node
        here.player_choice = choice;
        let comp_choice = here.computer_choice;

        # 2. Determine the result
        if here.player_choice == comp_choice {
            here.result = "draw";
        } else if (here.player_choice == "rock" and comp_choice == "scissors") or
                  (here.player_choice == "paper" and comp_choice == "rock") or
                  (here.player_choice == "scissors" and comp_choice == "paper") {
            here.result = "win";
            score += 1;
        } else {
            here.result = "lose";
        }

        print("Computer chose: " + here.computer_choice + ". Result: " + here.result);
        print("------------------------------");

        # 3. Check if the game is over or set up the next round
        if current_round_num < rounds {
            current_round_num += 1;

            # Update the game history for the LLM
            history += "player:" + here.player_choice + ",computer:" + here.computer_choice + "|";

            # Get the "smart" computer choice for the next round
            let llm_choice = get_llm_choice(history);

            # Validate LLM output; fall back to random if invalid
            if llm_choice != "rock" and llm_choice != "paper" and llm_choice != "scissors" {
                llm_choice = get_winning_choice[random.randint(0, 2)];
            }

            let next_node = spawn here ++> round(
                player_choice="",
                computer_choice=llm_choice,
                result=""
            );
            self.results.append(next_node);
            visit -> next_node;
        } else {
            # Game over: go to summary at root
            visit -> root;
        }
    }

    # Game results summary
    can summary with root entry {
        print("\n--- FINAL SUMMARY ---");
        print("Final Score: " + str(score) + "/" + str(results.length));

        for i in range(0, results.length) {
            let r = results[i];
            print("Round " + str(i + 1) + ": You chose " + r.player_choice + ", Computer chose " + r.computer_choice + " => " + r.result);
        }
        disengage
    }
}

// --- Main Execution ---
with entry {
    // Start the walker, which takes over the interactive loop
    RPSGame() spawn root;
}

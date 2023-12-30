#!/bin/zsh

API_URL="https://opentdb.com/api.php?amount=10"

response=$(curl -s "$API_URL")
questionNumber=0;
correctResponses=0;

if [[ $(echo "$response" | jq -r '.response_code') == "0" ]]; then
    
    data=$(echo "$response" | jq '.results')
    
    # Parse JSON and ask questions
    #questions=$(echo "$response" | jq -r '.results['$questionNumber'] .question[]')

    for i in {0..9}; do
        # Parse JSON
        question=$(echo "$response" | jq '.results['$i'] .question')
        correctAnswer=$(echo "$response" | jq '.results['$i'] .correct_answer')
        incorrectAnswer1=$(echo "$response" | jq '.results['$i'] .incorrect_answers[0]')
        incorrectAnswer2=$(echo "$response" | jq '.results['$i'] .incorrect_answers[1]')
        incorrectAnswer3=$(echo "$response" | jq '.results['$i'] .incorrect_answers[2]')
        isTrueFalse=$(echo "$response" | jq '.results['$i'] .type')

        # Print question
        echo "------------------------"
        echo "$question" | textutil -convert txt -format html -stdin -stdout
        echo "\n"

        #create array of answers and shuffle answers and print
        answers=($correctAnswer $incorrectAnswer1 $incorrectAnswer2 $incorrectAnswer3); shuf -e ${answers[@]} | textutil -convert txt -format html -stdin -stdout
        echo "\n"
        echo "What is your answer?"

        # Read answer
        read answer
        answer=$answer | textutil -convert txt -format html -stdin -stdout

        # Append quotes to answer variable
        answer="\"$answer\""
        
        # Display user's answer and correct answer
        echo "You answered: $answer"
        echo "Correct answer: $correctAnswer"

        # Color output
        RED='\033[0;31m'
        GREEN='\033[0;32m'
        NC='\033[0m' # No Color

        # Check if answer is correct
        if [[ $answer == $correctAnswer ]]; then
            echo -e "${GREEN}Correct!${NC}"
            correctResponses=$(($correctResponses+1))
        else
            echo -e "${RED}Incorrect!${NC}"
        fi
        echo "------------------------"
        questionNumber=$(($questionNumber+1))
    done
    echo "You got $correctResponses out of 10 questions correct!"
    echo "Thanks for playing!"
    echo "Do you want to save your score? (y/n)"
    read saveScore
    if [[ $saveScore == "y" ]]; then
        timestamp=$(date +"%Y-%m-%d %H:%M:%S,%3N")
        echo "What is your name?"
        read name
        echo "Saving score..."
        echo "$name: $correctResponses - $timestamp" >> scores.txt
        echo "Score saved!"
    fi

    # Display scores
    echo "Would you like to see the saved scores? (y/n)"
    read seeScores
    if [[ $seeScores == "y" ]]; then
        echo "------------------------"
        cat scores.txt
        echo "------------------------"
    fi



else
    echo "Error: Failed to retrieve data from the API"
fi
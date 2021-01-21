#!/bin/bash

declare -A board  # associative array symulates 2D array
declare -A user_board
board_dimension=0  # base value
num_of_bombs=0
game_win=false
game_status=true

# declare colors
declare -A COLORS=(
          ["nc"]="\033[0m" 
          ["red"]="\033[0;31m" 
          ["green"]="\033[0;32m" 
          ["orange"]="\033[0;33m" 
          ["blue"]="\033[0;34m" 
          ["purple"]="\033[0;35m" 
          ["cyan"]="\033[0;36m" 
          ["dark_red"]="\033[2;31m" 
          ["light_green"]="\033[1;32m" 
          ["yellow"]="\033[1;33m" 
          ["light_blue"]="\033[1;34m" 
          ["light_cyan"]="\033[1;36m"
          ["white"]="\033[1;37m" )

generate_board(){
    local i
    local j
    board_dimension=$1
    num_of_bombs=$2

    # fill with 0's
    for ((i = 0 ; i < ${board_dimension} ; i++)); do
        for ((j = 0 ; j < ${board_dimension} ; j++)); do
            board["$i,$j"]=0
        done
    done

    # place bombs and update array numbers
    for ((i = 0 ; i < ${num_of_bombs} ; i++)); do
        x=$((RANDOM % ${board_dimension}))
        y=$((RANDOM % ${board_dimension}))
        
        while [ true ]; do
            if [ ${board["$x,$y"]} != "X" ];then
                board["$x,$y"]="X"
                break
            else
                x=$((RANDOM % ${board_dimension}))
                y=$((RANDOM % ${board_dimension}))
            fi
        done
    
        # center right
        if [[ $y -ge 0 && $y -le $(($board_dimension - 2)) && $x -ge 0 && $x -le $(($board_dimension - 1)) ]]; then 
            if [[ ${board["$x,$(($y + 1))"]} != "X" ]]; then
                board["$x,$(($y + 1))"]=$((${board["$x,$(($y + 1))"]} + 1))
            fi
        fi
        
        #center left
        if [[ $y -ge 1 && $y -le $(($board_dimension - 1)) && $x -ge 0 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${board["$x,$(($y - 1))"]} != "X" ]]; then
                board["$x,$(($y - 1))"]=$((${board["$x,$(($y - 1))"]} + 1))
            fi
        fi

        # top left
        if [[ $y -ge 1 && $y -le $(($board_dimension - 1)) && $x -ge 1 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${board["$(($x - 1)),$(($y - 1))"]} != "X" ]]; then
                board["$(($x - 1)),$(($y - 1))"]=$((${board["$(($x - 1)),$(($y - 1))"]} + 1))
            fi
        fi
        
        # top right
        if [[ $y -ge 0 && $y -le $(($board_dimension - 2)) && $x -ge 1 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${board["$(($x - 1)),$(($y + 1))"]} != "X" ]]; then
                board["$(($x - 1)),$(($y + 1))"]=$((${board["$(($x - 1)),$(($y + 1))"]} + 1))
            fi
        fi

        # top center
        if [[ $y -ge 0 && $y -le $(($board_dimension - 1)) && $x -ge 1 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${board["$(($x - 1)),$y"]} != "X" ]]; then
                board["$(($x - 1)),$y"]=$((${board["$(($x - 1)),$y"]} + 1))
            fi
        fi

        # bottom right
        if [[ $y -ge 0 && $y -le $(($board_dimension - 2)) && $x -ge 0 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${board["$(($x + 1)),$(($y + 1))"]} != "X" ]]; then
                board["$(($x + 1)),$(($y + 1))"]=$((${board["$(($x + 1)),$(($y + 1))"]} + 1))
            fi
        fi

        # bottom left
        if [[ $y -ge 1 && $y -le $(($board_dimension - 1)) && $x -ge 0 && $x -le $(($board_dimension - 2)) ]]; then
            if [[ ${board["$(($x + 1)),$(($y - 1))"]} != "X" ]]; then
                board["$(($x + 1)),$(($y - 1))"]=$((${board["$(($x + 1)),$(($y - 1))"]} + 1))
            fi
        fi

        # bottom center
        if [[ $y -ge 0 && $y -le $(($board_dimension - 1)) && $x -ge 0 && $x -le $(($board_dimension - 2)) ]]; then
            if [[ ${board["$(($x + 1)),$y"]} != "X" ]]; then
                board["$(($x + 1)),$y"]=$((${board["$(($x + 1)),$y"]} + 1))
            fi
        fi
    done
    generate_user_board
}

check_for_win(){
    local i
    local j

    current_free=$(($board_dimension * $board_dimension))
    for ((i = 0 ; i < ${board_dimension} ; i++)); do
        for ((j = 0 ; j < ${board_dimension} ; j++)); do
            if [ ${user_board["$i,$j"]} != "-" ];then
                current_free=$(($current_free - 1))
            fi
        done
    done

    if [ $current_free -eq $num_of_bombs ]; then
        game_win=true
    fi
}

generate_user_board(){
    # fill with -'s
    local i
    local j
    for ((i = 0 ; i < ${board_dimension} ; i++)); do
        for ((j = 0 ; j < ${board_dimension} ; j++)); do
            user_board["$i,$j"]="-"
        done
    done
}

print_board(){
    # RED="\033[1;33m"
    # NC="\033[0m"
    # GREEN="\033[0;32m"
    local i
    local t
    local line
    local -n current_board=$1
    local current_num

    # x axis numeration
    for ((i = 0 ; i < ${board_dimension} ; i++)); do
        len=${#i}
        if [[ $i -eq 0 ]]; then
            printf "   "
        fi

        if [[ $len -eq 1 ]]; then
            printf "  ${COLORS[light_cyan]}${i}${COLORS[nc]} "
        else
            printf "  ${COLORS[light_cyan]}${i}${COLORS[nc]}"
        fi
    done
    printf "\n"

    # main board
    for ((i = 0 ; i < ${board_dimension} ; i++)); do  # row

        # separators
        for ((t = 0 ; t < $((board_dimension * 4 + 1)) ; t++)); do
            
            if [[ $t -eq 0 ]]; then
                printf "   "
            fi
            printf "${COLORS[white]}-${COLORS[nc]}"
        done

        printf "\n"

        # y axis numeration
        len=${#i}
            if [[ $len -eq 1 ]]; then
                printf " ${COLORS[light_cyan]}${i}${COLORS[nc]} "
            else
                printf "${COLORS[light_cyan]}${i}${COLORS[nc]} "
            fi

        # mines
        for ((line = 0 ; line < ${board_dimension} ; line++)); do
            
            # pick color
            current_num=${current_board[$i,$line]}
            if [[ 0 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[yellow]}${current_num}${COLORS[nc]} "
            elif [[ 1 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[light_blue]}${current_num}${COLORS[nc]} " 
            elif [[ 2 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[green]}${current_num}${COLORS[nc]} " 
            elif [[ 3 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[red]}${current_num}${COLORS[nc]} " 
            elif [[ 4 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[light_blue]}${current_num}${COLORS[nc]} " 
            elif [[ 5 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[dark_red]}${current_num}${COLORS[nc]} " 
            elif [[ 6 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[cyan]}${current_num}${COLORS[nc]} " 
            elif [[ 7 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[orange]}${current_num}${COLORS[nc]} " 
            elif [[ 8 == $current_num ]]; then
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[purple]}${current_num}${COLORS[nc]} " 
            else
                printf "${COLORS[white]}|${COLORS[nc]} ${COLORS[white]}${current_num}${COLORS[nc]} "
            fi

            
            if [[ $(($line + 1)) -eq $board_dimension ]]; then
                printf "${COLORS[white]}|${COLORS[light_green]}\n"
            fi
        done
    done

    # separators
    for ((t = 0 ; t < $((board_dimension * 4 + 1)) ; t++)); do
        if [[ $t -eq 0 ]]; then
            printf "   "
        fi
        printf "${COLORS[white]}-${COLORS[nc]}"
    done
    printf "\n"
}

check_neighbours(){
    local i
    local x=$1
    local y=$2

    # check neigbours
    for ((i = 0 ; i < ${num_of_bombs} ; i++)); do

        # center right
        if [[ $y -ge 0 && $y -le $(($board_dimension - 2)) && $x -ge 0 && $x -le $(($board_dimension - 1)) ]]; then 
            if [[ ${user_board["$x,$(($y + 1))"]} == "-" && ${board["$x,$(($y + 1))"]} -eq 0 ]]; then
                user_board["$x,$(($y + 1))"]=${board["$x,$(($y + 1))"]}  # reveal 0 and go next recursion
                check_neighbours $x $(($y + 1))
            else
                user_board["$x,$(($y + 1))"]=${board["$x,$(($y + 1))"]}  # reveal number
            fi
        fi

       #center left
        if [[ $y -ge 1 && $y -le $(($board_dimension - 1)) && $x -ge 0 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${user_board["$x,$(($y - 1))"]} == "-" && ${board["$x,$(($y - 1))"]} -eq 0 ]]; then
                user_board["$x,$(($y - 1))"]=${board["$x,$(($y - 1))"]}  # reveal 0 and go next recursion
                check_neighbours $x $(($y - 1))
            else
                user_board["$x,$(($y - 1))"]=${board["$x,$(($y - 1))"]}  # reveal number
            fi
        fi

        # top left
        if [[ $y -ge 1 && $y -le $(($board_dimension - 1)) && $x -ge 1 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${user_board["$(($x - 1)),$(($y - 1))"]} == "-" && ${board["$(($x - 1)),$(($y - 1))"]} -eq 0 ]]; then
                user_board["$(($x - 1)),$(($y - 1))"]=${board["$(($x - 1)),$(($y - 1))"]}  # reveal 0 and go next recursion
                check_neighbours $(($x - 1)) $(($y - 1))
            else
                user_board["$(($x - 1)),$(($y - 1))"]=${board["$(($x - 1)),$(($y - 1))"]}  # reveal number
            fi
        fi
        
        # top right
        if [[ $y -ge 0 && $y -le $(($board_dimension - 2)) && $x -ge 1 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${user_board["$(($x - 1)),$(($y + 1))"]} == "-" && ${board["$(($x - 1)),$(($y + 1))"]} -eq 0 ]]; then
                user_board["$(($x - 1)),$(($y + 1))"]=${board["$(($x - 1)),$(($y + 1))"]}  # reveal 0 and go next recursion
                check_neighbours $(($x - 1)) $(($y + 1))
            else
                user_board["$(($x - 1)),$(($y + 1))"]=${board["$(($x - 1)),$(($y + 1))"]}  # reveal number
            fi
        fi

        # top center
        if [[ $y -ge 0 && $y -le $(($board_dimension - 1)) && $x -ge 1 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${user_board["$(($x - 1)),$y"]} == "-" && ${board["$(($x - 1)),$y"]} -eq 0 ]]; then
                user_board["$(($x - 1)),$y"]=${board["$(($x - 1)),$y"]}  # reveal 0 and go next recursion
                check_neighbours $(($x - 1)) $y
            else
                user_board["$(($x - 1)),$y"]=${board["$(($x - 1)),$y"]}  # reveal number
            fi
        fi

        # bottom right
        if [[ $y -ge 0 && $y -le $(($board_dimension - 2)) && $x -ge 0 && $x -le $(($board_dimension - 1)) ]]; then
            if [[ ${user_board["$(($x + 1)),$(($y + 1))"]} == "-" && ${board["$(($x + 1)),$(($y + 1))"]} -eq 0 ]]; then
                user_board["$(($x + 1)),$(($y + 1))"]=${board["$(($x + 1)),$(($y + 1))"]}  # reveal 0 and go next recursion
                check_neighbours $(($x + 1)) $(($y + 1))
            else
                user_board["$(($x + 1)),$(($y + 1))"]=${board["$(($x + 1)),$(($y + 1))"]}  # reveal number
            fi
        fi

        # bottom left
        if [[ $y -ge 1 && $y -le $(($board_dimension - 1)) && $x -ge 0 && $x -le $(($board_dimension - 2)) ]]; then
            if [[ ${user_board["$(($x + 1)),$(($y - 1))"]} == "-" && ${board["$(($x + 1)),$(($y - 1))"]} -eq 0 ]]; then
                user_board["$(($x + 1)),$(($y - 1))"]=${board["$(($x + 1)),$(($y - 1))"]}  # reveal 0 and go next recursion
                check_neighbours $(($x + 1)) $(($y - 1))
            else
                user_board["$(($x + 1)),$(($y - 1))"]=${board["$(($x + 1)),$(($y - 1))"]}  # reveal number
            fi
        fi

        # bottom center
        if [[ $y -ge 0 && $y -le $(($board_dimension - 1)) && $x -ge 0 && $x -le $(($board_dimension - 2)) ]]; then
            if [[ ${user_board["$(($x + 1)),$y"]} == "-" && ${board["$(($x + 1)),$y"]} -eq 0 ]]; then
                user_board["$(($x + 1)),$y"]=${board["$(($x + 1)),$y"]}  # reveal 0 and go next recursion
                check_neighbours $(($x + 1)) $y
            else
                user_board["$(($x + 1)),$y"]=${board["$(($x + 1)),$y"]}  # reveal number
            fi
        fi
    done
}

start_game(){
    clear
    while $game_status ; do
        read -p "Choose difficulty (easy - type 'e', normal - type 'n', hard - type 'h', custom - type 'c'): " difficulty

        # choose difficulty
        if [[ $difficulty == "e" ]]; then
            generate_board 5 3
        elif [[ $difficulty == "n" ]]; then
            generate_board 10 10
        elif [[ $difficulty == "h" ]]; then
            generate_board 18 40
        elif [[ $difficulty == "c" ]]; then
            read -p "Choose map dimension (min 5, max 35): " custom_dimension
            if [[ $custom_dimension -gt 35 || $custom_dimension -lt 5 ]]; then
                printf "Wrong dimension!\n"
                game_status=false
                break
            fi
            # read -p "Choose bomb number (max 100): " custom_num_of_bombs
            generate_board $custom_dimension $(($custom_dimension * 5))
        else
            echo "Wrong input!"
            exit
        fi

        # main loop
        while true; do
            print_board user_board
            if ! $game_win; then  # if 'game win' is false
                echo "Enter cell coordinates you want to open: "
                read -p "X (0-$(($board_dimension - 1))): " user_x
                read -p "X (0-$(($board_dimension - 1))): " user_y
                printf "\n"

                # # validate input
                # if [[ $user_x -lt 0 || $user_x -gt $(($board_dimension - 1)) || $user_y -lt 0 || $user_y -gt $(($board_dimension - 1)) ]]; then
                #     clear
                #     printf "Wrong coordinates! Try again\n\n"
                #     continue
                # fi
                
                # hit mine
                if [[ ${board["$user_x,$user_y"]} == "X" ]]; then
                    clear
                    print_board board
                    echo "Sorry, you lost!"

                    read -p "Try again?(y/n): " try_again

                    # try again
                    if [[ $try_again == "y" ]]; then
                        generate_board $board_dimension $num_of_bombs
                        printf "\n"
                        clear
                    elif [[ $try_again == "n" ]]; then
                        echo "Bye!"
                        game_status=false
                        break
                    else
                        echo "Unknown command, exiting.."
                        game_status=false
                        break
                    fi

                # already guessed or wrong
                elif [[ ${user_board["$user_x,$user_y"]} != "-" ]]; then
                    clear
                    printf "You alredy guessed those coordinates / Wrong coordinates!\n\n"
                    continue

                # all good
                else
                    clear
                    printf "Good! Guess next number\n\n"
                    current_coords_num=${board["$user_x,$user_y"]}
                    user_board["$user_x,$user_y"]=$current_coords_num

                    if [[ $current_coords_num -eq 0 ]]; then
                        check_neighbours $user_x $user_y
                    fi
                fi
                check_for_win
            else
                clear
                print_board board
                echo "You won, congrats!"
                game_status=false
                break
            fi
            
        done
    done
}

start_game



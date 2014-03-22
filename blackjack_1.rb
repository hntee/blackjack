def clear_screen
  system('clear')
end

def get_name

  puts 'What is your name?'
  name = gets.chomp

  if name.strip.length == 0
    puts 'Not a valid name. Please input again.',''
    get_name
  end

  name

end

def generate_deck
  suits = ['S', 'H', 'D', 'C']
  num = ['A','2','3' ,'4','5','6','7',
           '8','9','10','J','Q','K']
  deck = num.product(suits)
         .collect {|x,y| x + y}
end

# you can flush n decks
def flush_deck (n = 1)

  deck = []
  n.times { deck.concat(generate_deck) }

  # swap two random cards (4 * deck.length) times
  (4 * deck.length).times do
    
    i, j = rand(deck.length), rand(deck.length)
    deck[i], deck[j] = deck[j], deck[i]

  end

  deck

end

# return n cards from the top of the deck
def deal (n, deck)
  cards = []
  n.times {cards << deck.pop}
  cards
end

def calc_points (cards)

  # move aces to the end of the array
  aces = cards.select {|e| e.match(/A/)}
  cards -= aces
  cards += aces

  $points = 0

  cards.each do |card| 

    # omit suits
    num = card.match(/[^SHDC]+/)
    
    # count the points
    if num.to_s.match(/[0-9]/)
      $points += num.to_s.to_i
    elsif num.to_s.match(/[JQK]/)
      $points += 10
    else # just remain Aces
      if $points < 11
        $points += 11
      else
        $points += 1
      end
    end

  end

  $points

end

def bust? (points)
  points > 21
end

def compare (dealer_points, player_points)
  diff = dealer_points - player_points
  case 
  when diff == 0
    puts 'Push!'
  when diff > 0
    puts 'You lose!'
  when diff < 0
    puts 'You win!'
  end
end

def display_cards_and_points (name, cards, init = 0)
  
  # only view one card of the dealer's when game starts
  if init == 1
    visible_card = [cards[0]]
    points = calc_points(visible_card)
    puts "One of the dealer's card is #{visible_card}"
    puts "The dealer has at least #{points} points."
    return
  end

  # normal case
  points = calc_points(cards)
  case name
  when 'player'
    puts("Your cards are #{cards}.")
    puts("You have #{points} points.")
  when 'dealer'
    puts("The dealer's cards are #{cards}.")
    puts("The dealer has #{points} points.")
  end

end

def dealer_control (name, deck, dealer_cards)

  display_cards_and_points('dealer', dealer_cards)

  while calc_points(dealer_cards) < 17

    new_card = deal(1,deck)
    dealer_cards.concat(new_card)

    puts 'Dealer\'s got a new card.'
    display_cards_and_points('dealer', dealer_cards)

  end

  if bust?(calc_points(dealer_cards))
    puts 'Dealer Busted. You win!'
    play_or_exit(name)
  elsif calc_points(dealer_cards) == 21
    puts 'Dealer\'s got Blackjack. You lose.'
    play_or_exit(name)
  end

end


def player_control (name, deck, hand_cards)

  while true

    display_cards_and_points('player', hand_cards)

    input = prompt?(name, 'do you want to hit or stay?','h','s')

    if input # is hit

      hand_cards.concat(deal(1,deck))
      player_points = calc_points(hand_cards)

      if bust?(player_points)

        display_cards_and_points('player', hand_cards)
        puts 'Bust!'
        play_or_exit(name)

        
      end

      if player_points == 21

        display_cards_and_points('player', hand_cards)
        puts 'Blackjack! You win!'
        play_or_exit(name)
        
      end

    else # input is stay
      break
    end

  end
      
end


def prompt? (name, msg, a, b)
  puts "#{name}, #{msg} (#{a}/#{b})"
  input = gets.chomp.downcase
  
  while (input != a && input != b)
    puts "Not a valid input. Please input again. (#{a}/#{b})"
    input = gets.chomp.downcase
  end

  input == a 

end


def play_again? (name)
  prompt?(name, 'do you want to play it again?','y','n')
end

def play_or_exit (name)
  if play_again?(name)
    play(name)
  else
    abort
  end
end

def play (name)

  clear_screen
  deck = flush_deck

  hand_cards = deal(2, deck)
  dealer_cards = deal(2, deck)
  
  display_cards_and_points('dealer', dealer_cards, init = 1)

  if calc_points(hand_cards) == 21

    display_cards_and_points('player', hand_cards)
    puts 'Blackjack! You win!'
    play_or_exit(name)
    
  end

  player_control(name, deck, hand_cards)
  dealer_control(name, deck, dealer_cards)

  compare(calc_points(dealer_cards), 
          calc_points(hand_cards))

  play_or_exit(name)

end

def start

  clear_screen
  puts 'Welcome to Blackjack Game!'
  name = get_name
  play(name)

end

start

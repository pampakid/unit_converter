class TemperatureConverter
  def initialize
    @temperatures = []          # Array to store all converted temperatures --basic data structure
    @conversion_stack = []      # Stack to store conversion history for undo functionality () --abstract data type
    @conversion_queue = []      # Stack to store conversion history for undo functionality --abstract data type
  end

  def celsius_to_fahrenheit(celsius)
    if celsius.between?(-273.15, 1_000_000)     # Check if temperature is within range 
      fahrenheit = (celsius * 9/5) + 32         # Convert Celsius to Fahrenheit
      @temperatures << fahrenheit               # Add the converted temperature to the history
      @conversion_stack.push({ celsius: celsius, fahrenheit: fahrenheit })      # Add to undo stack
      fahrenheit                                # Return the converted temperature
    else
      raise InvalidTemperatureError, "Temperature must be between -273.15°C and 1,000,000°C"
    end
  end

  def undo_conversion
    if last_conversion = @conversion_stack.pop      # Remove and return the last conversion from the stack
      @temperatures.pop     # Remove the last added temperature from the history
      last_conversion       # Return the removed conversion
    end
  end

  def queue_conversion(celsius)
    @conversion_queue.push(celsius)     # Add a temperature to the queue for later conversion
  end

  def process_queue
    results = []
    until @conversion_queue.empty?                  # Continue until the queue is empty
      celsius = @conversion_queue.shift             # Remove and return the first item from the queue
      results << celsius_to_fahrenheit(celsius)     # Convert the temprature and add to results
    end
    results
  end

  def next_in_queue
    @conversion_queue.first  # Return the first item in the queue without removing it
  end

  def queue_size
    @conversion_queue.size  # Return the number of items in the queue
  end

  def average_temperature
    raise ArgumentError, "No temperatures recorded" if @temperatures.empty?     # Raise an ArgumentError if no conversions have been made
    @temperatures.sum / @temperatures.size      
  end

  def conversion_count
    @temperatures.size      # Return the number of conversions made
  end
end

class InvalidTemperatureError < StandardError; end      # Custom error class for invalid temperatures

# Main program
converter = TemperatureConverter.new      # Create a new TemperatureConverter object

loop do  # Start an infinite loop for the menu system
  puts "\nTemperature Converter Menu:"
  puts "1. Convert Celsius to Fahrenheit"
  puts "2. Undo last conversion"
  puts "3. Queue a conversion"
  puts "4. Process queued conversions"
  puts "5. View next in queue"
  puts "6. View queue size"
  puts "7. View average temperature"
  puts "8. View number of conversions"
  puts "9. Exit"
  print "Enter your choice: "
  
  choice = gets.chomp.to_i  # Get user input and convert to integer (to_i)

  case choice
  when 1
    print "enter temperature in Celsius:"
    celsius = gets.chomp.to_f     # Get tempreature input and convert to float for later calculation
    begin
      fahrenheit = converter.celsius_to_fahrenheit(celsius)     # Convert temp using converter object & call methods from it
      puts "#{celsius}°C is equal to #{fahrenheit.round(2)}°F"
      rescue InvalidTemperatureError => e
        puts "Error: #{e.message}"  # Handle invalid temperature error
      end
  when 2
    last_conversion = converter.undo_conversion     # Undo the last conversion
    if last_conversion
      puts "Undone: #{last_conversion[:celsius]}°C was #{last_conversion[:fahrenheit].round(2)}°F"
    else 
      puts "No conversions to undo."
    end
  when 3
    print "Enter temperature in Celsius to queue: "
    celsius = gets.chomp.to_f     # Get temperature input for queuing
    converter.queue_conversion(celsius)     # Add temperature to queue
    puts "Temperature queued for conversion."
  when 4
    results = converter.process_queue     # Process all queued conversions
    if results.empty?
      puts "No temperatures in queue to process."
    else 
      results.each_with_index do |fahrenheit, index|
        puts "Conversion #{index + 1}: #{fahrenheit.round(2)}°F"
      end
    end
  when 5
    next_temp = converter.next_in_queue     # Get the next in the queue
    if next_temp
      puts "Next temperature in queue: #{next_temp}°C"
    else
      puts "Queue is empty."
    end
  when 6
    puts "Current queue size: #{converter.queue_size}"      # Display the size of the queue
  when 7
    avg = converter.average_temperature     # Calculate and display average temp
    if avg
      puts "Average temperature: #{avg.round(2)}°F"
    else
      puts "No conversions were performed yet."
    end
  when 8
    puts "Number of conversions: #{converter.conversion_count}"
  when 9
    puts "Thank you for using the Temperature Converter!"
    break     # Exit the loop and end the program
  else
    puts "Invalid choice. Please try again."      # Handle invalid menu choices
  end
end
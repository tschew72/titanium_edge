# current_valuation = 0
# current_karma = 0

# SCHEDULER.every '2s' do
#   last_valuation = current_valuation
#   last_karma     = current_karma
#   current_valuation = rand(100)
#   current_karma     = rand(200000)

#   send_event('valuation', { current: current_valuation, last: last_valuation })
#   send_event('karma', { current: current_karma, last: last_karma })
#   send_event('synergy',   { value: rand(100) })
# end

# require 'roo'

# EM.kqueue = true if EM.kqueue?
# file_path = "#{Dir.pwd}/spreadsheet.csv"


# def fetch_spreadsheet_data(path,last_entered_score)
#   s = Roo::CSV.new(path)
#   current_score = s.cell(2, 5)
#   puts ("STEP 1 last score =  #{last_entered_score} Current Score= #{current_score}")
#   send_event('career_score',   { current: current_score, last: last_entered_score })
#   @last_entered_score     = current_score
#   puts ("STEP 2 last score =  #{last_entered_score} Current Score= #{current_score}")
#   return current_score
# end


# module Handler
#   def file_modified
#   	puts "Modified"
#     fetch_spreadsheet_data(path, $last_score)
#     $last_score = fetch_spreadsheet_data(path, $last_score)
#   end
#   def file_moved
#   	puts "Moved"
#     fetch_spreadsheet_data(path)
#   end
#   def file_deleted
#   	puts "Deleted"
#   end  
#   def unbind
#     puts "#{path} monitoring ceased"
#   end
# end


# 	$last_score=fetch_spreadsheet_data(file_path, $last_score)
#     puts ("STEP 0 #{$last_score}")

# 	EM.next_tick do
# 	  t= EM.watch_file(file_path, Handler)
# 	end


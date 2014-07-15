require 'httparty'
require 'json'
require 'roo'

file_path = "#{Dir.pwd}/spreadsheet.csv"  #Only CSV will not give us any issue.



last_transaction = 0
$last_score=0


SCHEDULER.every '5s', allow_overlapping: false do
 
s = Roo::CSV.new(file_path)

### CAREER SCORE ###

	def fetch_spreadsheet_data(path)
		s = Roo::CSV.new(path)
		current_score = s.cell(2, 5)
		if current_score == $last_score
			#puts ("do nothing!")
		else
			send_event('seeker_profile',   { current: current_score, last: $last_score})
		#HTTParty.post('http://dashy3.herokuapp.com/widgets/career_score', :body => { auth_token: "YOUR_AUTH_TOKEN", current: current_score, last: $last_score }.to_json)
		end
		$last_score = current_score
	end
	fetch_spreadsheet_data(file_path)

### RECENT TOP MATCHES ###
    puts "TTT  #{@username}"
	rt_labels=[]
	rt_values=[]
	(2..6).each do |i|
		match_qty = s.cell(i,10)
		rt_labels << [s.cell(i,9)]
		rt_values << [match_qty+" matches"]
	end 
	rt_send=[]
	(0..4).each do |i|
		rt_hash = {}
		rt_hash["label"] = rt_labels[i]
		rt_hash["value"] = rt_values[i]
		rt_send << rt_hash
	end  
	send_event('recent_top_matches', { items: rt_send })
	#HTTParty.post('http://dashy3.herokuapp.com/widgets/recent_top_matches', :body => { auth_token: "YOUR_AUTH_TOKEN", items: rt_send }.to_json)


### RECENT TOP MATCHES (NEW)###
 
	rtm_score=[]
	rtm_date=[]
	rtm_rank=[]
	rtm_job=[]
	rtm_level=[]
	rtm_salary=[]

	(21..30).each do |i|
		rtm_score << [s.cell(i,2)]
		rtm_date << [s.cell(i,1)]
		rtm_rank << [s.cell(i,3)]
		rtm_job << [s.cell(i,4)]
		rtm_level << [s.cell(i,5)]
		rtm_salary << [s.cell(i,6)]
	end 
	rtm_send=[]
	(0..9).each do |i|
		rtm_hash = {}
		rtm_hash["score"] = rtm_score[i]
		rtm_hash["date"] = rtm_date[i]
		rtm_hash["rank"] = rtm_rank[i]
		rtm_hash["job"] = rtm_job[i]
		rtm_hash["level"] = rtm_level[i]
        rtm_hash["salary"] = rtm_salary[i]
		rtm_send << rtm_hash
	end
	send_event('new_top_matches', { items: rtm_send })
	#HTTParty.post('http://dashy3.herokuapp.com/widgets/new_top_matches', :body => { auth_token: "YOUR_AUTH_TOKEN", items: rtm_send }.to_json)



### TOP 5 JOB TITLES ###

	qtylist=[]
	list2_array = []
	list2={}
	(2..6).each do |i| 
		qty_in=s.cell(i,8)
		qtylist << qty_in.to_i
	end
	list2 = { s.cell(2,7)=>qtylist[0],s.cell(3,7)=>qtylist[1], s.cell(4,7)=>qtylist[2], s.cell(5,7)=>qtylist[3], s.cell(6,7)=>qtylist[4]}
	list2 = list2.sort_by &:last
	list2.reverse!
	list2[0..4].each do |list|
	input_hash = Hash.new
	input_hash["name"] = list[0]
	input_hash["data"] = [list[1].to_i]
	input_hash["pointWidth"] = 500
	list2_array << input_hash
	end
	send_event('top_job_titles', { series: list2_array, color: '#d35400' })
	#HTTParty.post('http://dashy3.herokuapp.com/widgets/top_job_titles', :body => { auth_token: "YOUR_AUTH_TOKEN", series: list2_array, color: '#d35400' }.to_json)
  

  
  ### JOB SEEKERS BY NATIONALITY ###

	ex_keys=[]
	ex_data=[]
	(2..8).each do |i|
		ex_qty = s.cell(i,12)
		ex_keys << [s.cell(i,11)]
		ex_data << [ex_qty.to_i]
	end 

	sorted_seekers = ex_keys.zip(ex_data).sort_by &:last
	ex_cats = sorted_seekers.map { |ex| ex[0] }
	ex_data = sorted_seekers.map { |ex| ex[1] }
	send_event('seekers_nationality', { series: [{ data: ex_data }], categories: ex_cats, color: '#efad1b' })
	#HTTParty.post('http://dashy3.herokuapp.com/widgets/seekers_nationality', :body => { auth_token: "YOUR_AUTH_TOKEN", series: [{ data: ex_data }], categories: ex_cats, color: '#efad1b' }.to_json)



  ### TOP 5 INDUSTRIES (PIE CHART) ###

	top_industries=[]
	(2..6).each do |i| 
		qty = s.cell(i,4)
		top_industries << [s.cell(i,3),qty.to_i]
	end
	pie_series = [{ type: 'pie', name: 'Type', data: top_industries }]
	send_event('top_industries', { series: pie_series, color: '#f39c12' })
	#HTTParty.post('http://dashy3.herokuapp.com/widgets/top_industries', :body => { auth_token: "YOUR_AUTH_TOKEN", series: pie_series, color: '#f39c12' }.to_json)




### TOP 10 SKILLS ###

   top_it_jobs=[]
   (2..11).each do |i|
		qty = s.cell(i,2)
		top_it_jobs << [s.cell(i,1), qty.to_i]
    end
    top_it_jobs = top_it_jobs.sort_by{|k|k[1]}
    top_it_jobs.reverse!

    ti_cats = top_it_jobs.map { |list| list[0] }
    ti_data = top_it_jobs.map { |list| list[1] }
    send_event('top_it_jobs', { series: [{ name: 'Instruments', data: ti_data }], categories: ti_cats, color: '#2c3e50' })
    #HTTParty.post('http://dashy3.herokuapp.com/widgets/top_it_jobs', :body => { auth_token: "YOUR_AUTH_TOKEN", series: [{ name: 'Instruments', data: ti_data }], categories: ti_cats, color: '#2c3e50' }.to_json)







### # OF IT JOBS ###

	def fetch_itjobsqty_data(path)
	  s = Roo::CSV.new(path)
	  current_itjobs_qty = s.cell(2, 6)
	  if current_itjobs_qty == $last_itjobs_qty
	      #puts ("do nothing!")
	  else
	      #HTTParty.post('http://dashy3.herokuapp.com/widgets/no_of_it_jobs', :body => { auth_token: "YOUR_AUTH_TOKEN", current: current_itjobs_qty, last: $last_itjobs_qty}.to_json)
	      send_event('no_of_it_jobs', { current: current_itjobs_qty, last: $last_itjobs_qty })
	  end
	  $last_itjobs_qty = current_itjobs_qty
	end

	fetch_itjobsqty_data(file_path)




	end
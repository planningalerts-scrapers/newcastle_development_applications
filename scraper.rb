require 'scraperwiki'
require 'mechanize'

term_url  = "http://da.ballina.nsw.gov.au/Common/Common/terms.aspx"
thisweek  = "http://da.ballina.nsw.gov.au/Pages/XC.Track/SearchApplication.aspx?d=thisweek&k=LodgementDate&t=10,18"
thismonth = "http://da.ballina.nsw.gov.au/Pages/XC.Track/SearchApplication.aspx?d=thismonth&k=LodgementDate&t=10,18"
lastmonth = "http://da.ballina.nsw.gov.au/Pages/XC.Track/SearchApplication.aspx?d=lastmonth&k=LodgementDate&t=10,18"
info_url  = "http://da.ballina.nsw.gov.au/pages/xc.track/searchapplication.aspx?id="
comment_url = "mailto:council@ballina.nsw.gov.au"

time = Time.new

case ENV['MORPH_PERIOD']
  when 'lastmonth'
    dateFrom = (Date.new(time.year, time.month, 1) << 1).strftime('%d/%m/%Y')
    dateTo   = (Date.new(time.year, time.month, 1)-1).strftime('%d/%m/%Y')
    data_url = lastmonth
  when 'thismonth'
    dateFrom = Date.new(time.year, time.month, 1).strftime('%d/%m/%Y')
    dateTo   = Date.new(time.year, time.month, -1).strftime('%d/%m/%Y')
    data_url = thismonth
  else
    dateFrom = (Date.new(time.year, time.month, time.day)-7).strftime('%d/%m/%Y')
    dateTo   = Date.new(time.year, time.month, time.day).strftime('%d/%m/%Y')
    data_url = thisweek
end

puts "Scraping from " + dateFrom + " to " + dateTo + ", changable via MORPH_PERIOD variable"

agent = Mechanize.new
agent.gzip_enabled = false

page = agent.get(term_url)
form = page.form_with(:action => "./terms.aspx")
page = form.submit( form.button_with(:value => "I Agree") )

page = agent.get(data_url)
records = page.search(".result")

records.each do |r|
  record = { "council_reference" => "",
             "address"           => "",
             "description"       => "",
             "info_url"          => "",
             "comment_url"       => comment_url,
             "date_scraped"      => Date.today.to_s,
             "date_received"     => "" }

  record["council_reference"] = r.at("a").text.strip
  record["info_url"] = info_url + record["council_reference"]

  r.xpath("text()").each do |t|
    str = t.text.gsub!(/\s+/, " ").strip
    case
      when str.match(/^Address: /)
        record["address"] = str.sub! 'Address: ', ''
      when str.match(/^Development Applications - |^Complying Development - /)
        record["description"] = str
      when str.match(/^Lodged: /)
        str = str.sub! 'Lodged: ', ''
        record["date_received"] = Date.strptime(str, '%d/%m/%Y').to_s
    end
  end

  if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true)
    puts "Saving record " + record['council_reference'] + ", " + record['address']
#     puts record
    ScraperWiki.save_sqlite(['council_reference'], record)
  else
    puts "Skipping already saved record " + record['council_reference']
  end
end



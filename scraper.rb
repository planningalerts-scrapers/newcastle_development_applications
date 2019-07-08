<<<<<<< HEAD
require 'scraperwiki'
require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'pdftohtmlr'
require 'nokogiri'
require 'tempfile'

include PDFToHTMLR

comment_url = 'mailto:mail@ncc.nsw.gov.au?subject='
starting_url = 'http://www.newcastle.nsw.gov.au/Special-Pages/MediaFeed.aspx?rss=MediaFiles&directory=Documents&path=Development%20Applications/Weekly%20Notifications'
search_result_url = 'https://ecouncil.burwood.nsw.gov.au/eservice/daEnquiryDetails.do?index='

def commit(pdf_url, reference, address, description, comment_url, date)
  if (!reference)
    return
  end
  record = {
    'info_url' => pdf_url,
    'comment_url' => comment_url + CGI::escape("Development Application Enquiry: " + reference),
    'council_reference' => reference,
    'date_received' => Date.strptime(date, '%d_%B_%Y').to_s,
    'address' => address + ", NSW",
    'description' => description,
    'date_scraped' => Date.today.to_s
  }
  if (ScraperWiki.select("* from data where `council_reference`='#{record['council_reference']}'").empty? rescue true) 
    ScraperWiki.save_sqlite(['council_reference'], record)
    puts "Saving " + reference
  else
    puts "Skipping already saved record " + reference
  end
end

def scrape_pdf(agent, pdf_url, comment_url)
  /(?<date>\d{2}+(_|-)(\d{2}|\w)+(_|-)(19|20)\d\d)/ =~ pdf_url
  date = date.sub("-","_")
  date = date.sub("-","_")
  # Open PDF.
  doc = Nokogiri::HTML(PdfFileUrl.new(pdf_url).convert)
  # Fix encoding issues.
  content = doc.at('body').inner_text.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')

  # Parse out page data boundaries.
  pages = content.scan(/Public.*Notification.*Weekly.*Register.*?Newcastle.*City.*Council/m)
  
  pages.each do |data|
    # Split into lines.
    page = data.split("\n")
    reference, description, address = false
    # Data is formatted like this:
    # reference
    # address
    # suburb
    # description
    # cost
    # exhibition period
    i = 1
    ref_regexp = /\d{2}\/\d{5}.*/
    while i < page.size - 2 do
      line = page[i]
      if (line =~ ref_regexp)
        commit(pdf_url, reference, address, description, comment_url, date)
        reference = line

        # Reference numbers have a max length of 11. Longer means columns don't have \n
        if reference.length > 11
          reference = reference.slice(/\d{2}\/\d{5}[\.]?[0-9]?[0-9]?/)
          page.insert(i-1, reference) # Could insert anything here, to keep array length
        end

        street_address = page[i].sub(/\d{2}\/\d{5}[\.]?[0-9]?[0-9]?/, "") + " " + page[i + 1]
        suburb = page[i + 2]
        address = "#{street_address} #{suburb}"

        # Description is on several lines and will get concatenated.
        description = ""
        i += 3
        while i < page.size - 2 and !(page[i] =~ ref_regexp) do
          # Skip over cost and exhibition dates.
          if !(page[i].strip =~ /^\$[\d,]+$/ or page[i].strip =~ /\d+.*to.*\d+.*\d{4}/)
            description += page[i]
          end
          i += 1
        end
        i -= 1
      end
      i += 1
    end
    commit(pdf_url, reference, address, description, comment_url, date)
  end
end

agent = Mechanize.new

# Grab the starting page and go into each link to get a more reliable data format.
doc = agent.get(starting_url)
doc.search('item link').each do |link|
  begin
    scrape_pdf(agent, link.inner_text, comment_url)
  rescue => ex # Keep trying if something goes wrong
    puts link.inner_text + " failed"
    puts ex.message
  end
end
=======
#!/usr/bin/env ruby
Bundler.require

url = "https://property.ncc.nsw.gov.au/T1PRPROD/WebAppServices/ATDIS/atdis/1.0"

ATDISPlanningAlertsFeed.save(url, timezone="Sydney")
>>>>>>> be9463b6f73a687604ceed7fe382fa70b403feb4

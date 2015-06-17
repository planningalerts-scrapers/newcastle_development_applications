require 'scraperwiki'
require 'rubygems'
require 'mechanize'
require 'open-uri'
require 'pdftohtmlr'
require 'nokogiri'
require 'tempfile'

include PDFToHTMLR

comment_url = 'mailto:mail@ncc.nsw.gov.au?subject='
starting_url = 'http://www.newcastle.nsw.gov.au/building_and_planning/da_assessment/current_das/current_das'
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
  puts "Scraping " + pdf_url
  # Parse date out of URL.
  /(?<date>\d+_\w+_\d{4})/ =~ pdf_url

  # Open PDF.
  doc = Nokogiri::HTML(PdfFileUrl.new(pdf_url).convert)

  # Fix encoding issues.
  content = doc.at('body').inner_text.encode("UTF-16be", :invalid=>:replace, :replace=>"?").encode('UTF-8')

  # Parse out page data boundaries.
  pages = content.scan(/Exhibition.*Period.*?Newcastle.*City.*Council/m)
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
    # (optional repeated) more description
    i = 1
    ref_regexp = /\d{2}\/\d{4}/
    while i < page.size - 2 do
      line = page[i]
      if (line =~ ref_regexp)
        commit(pdf_url, reference, address, description, comment_url, date)
        reference = line
        address = page[i + 1] + " " + page[i + 2]
        description = page[i + 3]
        i += 4
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

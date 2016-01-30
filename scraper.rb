require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
data_exists = ScraperWiki.select("count(*) FROM sqlite_master WHERE type='table' AND name='data';")[0]["count(*)"]> 0

#  doc = Nokogiri::HTML(File.read(input_filename))
doc = Nokogiri::HTML(open("http://www.cmd.act.gov.au/open_government/inform/find-a-public-notice/all-public-notices"))
doc.xpath('//tbody/tr').each do |row|

  data = {}
  row.xpath('td').each do |col|
    data[col.attributes['data-title'].to_s.gsub(' ', '_').downcase] = col.text
  end
  link = row.search('a')[0]
  data['public_notice_title'] = link.text
  data['public_notice_url'] = link.attributes['href'].to_s
  #p data

  if data_exists
    existing = ScraperWiki.select("count(*) from data where public_notice_url='"+data['public_notice_url']+"' and details != ''")[0]["count(*)"]> 0
  end
  if not existing or not data_exists
    p data['public_notice_url']
    details = Nokogiri::HTML(open(data['public_notice_url']))
    data['details'] = details.css(".position-details").to_s
    data['details_text'] = details.css(".position-details").text.strip!
    # Write out to the sqlite database using scraperwiki library
    ScraperWiki.save_sqlite(['public_notice_url'], data)
  end

end



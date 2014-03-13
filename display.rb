DATA = 'congestive_heart_failure.pipe.txt'
# DATA = 'atrial fibrillation.pipe.txt'


class Treatment < Struct.new(:cui, :name, :mentions_by_date_range, :trend)
end

treatments = []
File.open(DATA, 'r') do |f|
  t = nil
  while(line = f.gets) do
    mentions, cui, name, date_range = line.chomp.split('|').map(&:strip).reject{|s| s.empty?}
    if t.nil? or cui != t.cui
      t = Treatment.new(cui, name)
      treatments << t

      t.mentions_by_date_range ||= {}
    end

    t.mentions_by_date_range[date_range] = mentions
  end
end

treatments.each do |t|
  split = (t.mentions_by_date_range['1996-2000'].to_i / 2)
  s1 = split + t.mentions_by_date_range['1991-1995'].to_i + t.mentions_by_date_range['1986-1990'].to_i + t.mentions_by_date_range['1980-1985'].to_i
  s2 = t.mentions_by_date_range['2001-2005'].to_i + t.mentions_by_date_range['2006-2010'].to_i + t.mentions_by_date_range['2011-2013'].to_i + split
  if s1+s2 > 20
    # t.trend = 'Upward' if  ((s2 + 0.01 / s1 + 0.01) - 1.0) > 4.0
    t.trend = 'Upward' if  s2.to_f / (s1.to_f+s2.to_f) > 0.70
  end
end

TEMPLATE = <<-HTML
  <html>
    <head>
      <link rel="stylesheet" href="http://netdna.bootstrapcdn.com/bootstrap/3.0.3/css/bootstrap.min.css">
      <style>
        td {
          text-align: center;
        }
        .highlight {
          background-color:#ffc;
        }
      </style>
    </head>

    <body>
      <table class="table table-bordered table-condensed" style="width:1000px">
        <tr>
          <th>Treatment Name (cui)</th>
          <th>1980-1985</th>
          <th>1986-1990</th>
          <th>1991-1995</th>
          <th>1996-2000</th>
          <th class="highlight">2001-2005</th>
          <th class="highlight">2006-2010</th>
          <th class="highlight">2011-2013</th>
          <th>Trend</th>
        </tr>
        <% treatments.each do |t| %>
          <tr>
            <td><%= t.name %> (<%= t.cui %>)</td>
            <td><%= t.mentions_by_date_range['1980-1985'] || '&nbsp;' %></td>
            <td><%= t.mentions_by_date_range['1986-1990'] || '&nbsp;' %></td>
            <td><%= t.mentions_by_date_range['1991-1995'] || '&nbsp;' %></td>
            <td><%= t.mentions_by_date_range['1996-2000'] || '&nbsp;' %></td>
            <td class="highlight"><%= t.mentions_by_date_range['2001-2005'] || '&nbsp;' %></td>
            <td class="highlight"><%= t.mentions_by_date_range['2006-2010'] || '&nbsp;' %></td>
            <td class="highlight"><%= t.mentions_by_date_range['2011-2013'] || '&nbsp;' %></td>
            <td><%= t.trend || '&nbsp;' %></td>
          </tr>
        <% end %>
      </table>
    </body>
  </html>
HTML

require 'erb'
erb = ERB.new(TEMPLATE)
puts erb.result
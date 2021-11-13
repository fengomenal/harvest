module Util
  module_function

  def partition_to_weeks(data, date_key)
    res = []
    res << [data.first]
    last_wday = data.first[date_key].wday
    data[1..-1].each do |day|
      if day[date_key].wday <= last_wday
        res << [day]
      else
        res.last << day
      end
      last_wday = day[date_key].wday
    end
    res
  end

  def partition_via(data, date_attr, date_key)
    res = []
    res << [data.first]
    last_key = data.first[date_key].send(date_attr)
    data[1..-1].each do |day|
      if day[date_key].send(date_attr) <= last_key
        res << [day]
      else
        res.last << day
      end
      last_key = day[date_key].send(date_attr)
    end
    res
  end

  def calculate_new_value(position, price_start, price_end)
    value = 0
    position.each do |ticker, allocation|
      shares = allocation / price_start[ticker]
      value += shares * price_end[ticker]
    end
    value
  end

  def calculate_performance(positions, price_history)
    value = 1.0
    performance = {}
    dates = positions.keys.sort
    dates[0..-2].each_with_index do |date, index|
      value = calculate_new_value(positions[date], price_history[date], price_history[dates[index + 1]])
      performance[date] = value
    end
    performance
  end
end

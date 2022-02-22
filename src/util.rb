module Harvest
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

    def calculate_new_value(portfolio, period_data)
      value = 1
      portfolio.each do |ticker, data|
        value += data[:allocation] * ((period_data[ticker]|| 0) - data[:price]) / data[:price]
      end
      value
    end
  end
end

module TimeWillTell
  module Helpers
    module DateRangeHelper

      def has_time(dt)
        dt.localtime.seconds_since_midnight > 0
      rescue NoMethodError
        false
      end

      def date_range(from_date, to_date, **options)
        return '' unless from_date && to_date

        format    = options.fetch(:format, :short)
        scope     = options.fetch(:scope, 'time_will_tell.date_range')
        separator = options.fetch(:separator, '—')
        show_year = options.fetch(:show_year, true)
        loc = options.fetch(:locale, I18n.locale)

        tl = ->(id, **opts) { I18n.t(id, **{ locale: loc }.merge(opts)) }

        month_names = (format.to_sym == :short) ?
          tl['date.abbr_month_names'] : tl['date.month_names']

        from_date, to_date = to_date, from_date if from_date > to_date
        from_date = from_date.localtime if from_date.respond_to?(:localtime)
        to_date = to_date.localtime if to_date.respond_to?(:localtime)
        from_time = has_time(from_date) ? from_date.to_s(:time) : nil
        to_time = to_date.to_s(:time) if from_time
        from_day = from_date.day
        to_day = to_date.day
        from_month = month_names[from_date.month]
        to_month   = month_names[to_date.month]
        from_year  = from_date.year
        to_year    = to_date.year

        if (from_year == to_year) && (from_month == to_month) && 
            (from_day == to_day)
          template = :same_date
          from_day = "#{from_day}, #{from_time}#{separator}#{to_time}" if from_time
        else
          if from_time
            from_day = "#{from_day}, #{from_time}"
            to_day = "#{to_day}, #{to_time}"
          end
          template = if from_year == to_year
                       if (from_month == to_month) && !from_time
                         :same_month
                       else
                         :different_months_same_year
                       end
                     else
                       :different_years
                     end
        end

        dates = { from_day: from_day, to_day: to_day, from_month: from_month,
                  to_month: to_month, from_year: from_year, to_year: to_year,
                  month: from_month, year: from_year, sep: separator, }

        without_year = tl["#{scope}.#{template}", **dates]

        if show_year && from_year == to_year
          tl["#{scope}.with_year", date_range: without_year, year: from_year,
             default: without_year]
        else
          without_year
        end
      end

    end
  end
end

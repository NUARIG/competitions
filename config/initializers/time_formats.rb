# frozen_string_literal: true

# Dates
# Default: MM/DD/YYYY
Date::DATE_FORMATS[:default] = '%m/%d/%Y'
# short_format: -M/-D/YY
Date::DATE_FORMATS[:short_format] = '%-m/%-d/%y'
# machine: YYYY-MM-DD
Date::DATE_FORMATS[:machine] = '%Y-%m-%d'

# Times
# Default: MM/DD/YYYY #:##AM
Time::DATE_FORMATS[:default] = '%m/%d/%Y %l:%M%P'
# Machine: YYYY-MM-DD
Time::DATE_FORMATS[:machine] = '%Y-%m-%d %T'

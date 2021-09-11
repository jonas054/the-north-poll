require 'uri'

# Copied from the google-qr gem at https://github.com/jhsu/google-qr and
# modified somewhat to work with Ruby 3.0.
#
# Copyright (c) 2014 Joseph Hsu
class GoogleQr # :nodoc:
  attr_accessor :data, :size, :use_https, :encoding, :error_correction, :margin,
                :html_options

  def initialize(opts = {})
    options = { size: '100x100', use_https: true }.merge!(opts)

    options.each { |key, value| send("#{key}=", value) }
  end

  def to_s
    raise 'Attribute @data is required for GoogleQr code' unless data

    params = ["chl=#{escape_string(data)}"]
    params << "chs=#{size}"
    params << "choe=#{encoding}" if encoding
    params << error_correction_params if error_correction_param?
    base_url + params.join('&')
  end

  def render
    if self.html_options
      html_options = ''

      self.html_options.each do |k, v|
        if k.to_s.length.positive? && v.to_s.length.positive?
          html_options += "#{k}='#{v}' "
        end
      end
    else
      html_options = nil
    end

    "<img src='#{self}'#{dimensions}#{html_options}/>"
  end

  private

  def dimensions
    return nil unless size

    height, width = size.split('x')
    " height='#{height}' width='#{width}' "
  end

  def base_url
    "http#{use_https ? 's' : ''}://chart.googleapis.com/chart?cht=qr&"
  end

  def error_correction_param?
    error_correction || margin
  end

  def error_correction_params
    param = if !error_correction && margin
              "L|#{margin}"
            elsif error_correction && !margin
              error_correction
            else
              "#{error_correction}|#{margin}"
            end

    "chld=#{escape_string(param)}"
  end

  def escape_string(string)
    CGI.escape(string)
  end
end

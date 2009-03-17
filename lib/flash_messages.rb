# module for handling flash messages in a way that allows safe insertion of html
# without risking CSS vulnerabilities
#
# Usage (in the controller):
# 
# flash[:error] = "Plain text error message" # for simple text messages. They will be escaped
# 
# flash[:error] = text_part("Plain text error message") # Same result as above
#
# flash[:warning] = html_part("<b>This will be output without escaping, so watch out what you enter here</b>")
# 
# Or, for complex messages:
# 
# flash[:complex_message] = message :error, html_part("<b>Beware</b>"), "this will be escaped", html_part("but this <b>won't</b>")
# 
# To safely output the messages use methods in FlashMessagesHelpers module

module FlashMessages

  # the first parameter is the severity. 
  # the other parameters are part of the message - either Strings or
  # OutputStreams::StreamParts (see output_streams plugin for details)
  def message(severity, *args)
    return FlashMessages::Message.new(severity, *args)
  end

  # Produces a stream part marked as html content
  def html_part(text)
    OutputStreams::StreamPart.new(:'text/html', text)
  end

  # Produces a stream part marked as plain text content
  def text_part(text)
    OutputStreams::StreamPart.new(:'text/plain', text)
  end

  class Message
    def initialize(severity, *parts)
      @severity = severity
      @parts = parts.map {|x| OutputStreams::StreamPart.to_stream_part x}
    end

    def self.to_message(msg, severity = nil)
      return nil if msg.nil?
      return msg if self === msg
      return new(severity, msg)
    end
  
    attr_reader   :parts
    attr_accessor :severity

    def << (part)
      @parts << OutputStreams::StreamPart.to_stream_part(part)
    end

    # methods forwarded to parts
    [:empty?, :blank?, :size, :length, :each].each do |sym|
      define_method sym do
        @parts.send sym
      end
    end
  end
end

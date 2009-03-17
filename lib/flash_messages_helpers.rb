module FlashMessagesHelpers
  def flash_message_output(message)
    output_stream(:'text/html', *message.parts)
  end

  def flash_for_symbol(sym)
    flash_message_output(FlashMessages::Message.to_message(flash[sym], sym))
  end

  # yields pairs - message severity and html representation of content
  # if flash contained a FlashMessage (created by message method), then severity will be taken
  # from that message. Otherwise the flash hash key will be yield
  # 
  # Examples:
  # 
  # if the controller code contained:
  # flash[:message] = message :notice, html_part("<b>Important</b>"), "10 < 100"
  # flash[:warning] = "1 < 2"
  # flash[:error] = html_part('<b>Bold</b>')
  # 
  # then the following will be yield (order unknown):
  # :notice, "<b>Important</b>10 &lt; 100"
  # :warning, "1 &lt; 2"
  # :error, "<b>Bold</b>"
  # 
  # As can be seen from above examples, text is html-escaped unless it was in html_part container
  # Severity is determined by the first parameter to <tt>message</tt> method or flash key for messages created
  # by simply supplying a string or html_part
  def flash_message_all
    flash.each do |k,v|
      m = FlashMessages::Message.to_message(v, k)
      next if m.nil?
      yield h(m.severity), flash_message_output(m)
    end
  end
end

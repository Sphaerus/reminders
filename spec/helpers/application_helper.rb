def finished_jquery_requests?
  evaluate_script '(typeof jQuery === "undefined") || (jQuery.active == 0)'
end

def wait_for_jquery
  sleep(0.001) until finished_jquery_requests?
end

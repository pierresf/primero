class PropertyEvaluator

  # 'record' is any Ruby object instance that is to be evualuated
  # 'expression' is a naive pseudo-ruby mehod chain that is evaluted on the record object
  # eg. "created_by_user.location.admin('district').location_code"
  def self.evaluate(record, expression)
    if expression.present?
      expression.split('.').reduce(record) do |acc, particle|
        particles =
        if particle.match(/^[\w\?]*\(.*\)$/)
          [particle.split('(').first]  + particle[0..-2].split('(').last.split(',')
        else
          [particle]
        end
        acc.try(*particles)
      end
    end
  end

end

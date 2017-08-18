class ArrayInput < SimpleForm::Inputs::Base
  def input
    template.text_area_tag("#{@builder.object_name}[#{attribute_name}][]")
  end
end

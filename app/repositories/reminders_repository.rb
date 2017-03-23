class RemindersRepository
  def all
    Reminder.all.order(:order)
  end

  def create(entity)
    entity.order = max_order.next
    persist entity
  end

  def update(entity)
    persist entity
  end

  def persist(entity)
    entity.save
  end

  def delete(entity)
    entity.destroy
  end

  def find(id)
    Reminder.find_by_id id
  end

  private

  def max_order
    Reminder.maximum(:order) || Reminder.new.order
  end
end

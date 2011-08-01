require 'date'

# TODO: in general: date formatting
class StaffPortalTransformer
  include NcsNavigator::Warehouse::Transformers::Database
  include NcsNavigator::Warehouse::Models::TwoPointZero

  bcdatabase :name => :ncs_staff_portal

  def prefix_id(base)
    "staff_portal-#{base}"
  end

  def staff_id(row)
    prefix_id(row.username)
  end

  def staff_yob(birth_date)
    birth_date.try(:year).to_s
  end

  def staff_age_range(birth_date)
    return "-6" unless birth_date
    age = (Date.today - birth_date) / 365.25
    case
    when age < 18; 1
    when age < 25; 2
    when age < 35; 3
    when age < 45; 4
    when age < 50; 5
    when age < 65; 6
    else; 7
    end.to_s
  end

  ###### STAFF

  def self.staff_subtable_with_username(subtable_name)
    %Q{SELECT sub.*, s.username FROM #{subtable_name} sub INNER JOIN staff s ON sub.staff_id=s.id}
  end

  produce_records(:staff) do |row|
    Staff.new(
      :staff_id        => staff_id(row),
      :staff_type      => row.staff_type_code,
      :staff_type_oth  => row.staff_type_other,
      :subcontractor   => row.subcontractor_code,
      :staff_gender    => row.gender_code,
      :staff_race      => row.race_code,
      :staff_race_oth  => row.race_other,
      :staff_ethnicity => row.ethnicity_code,
      :staff_exp       => row.experience_code,
      :staff_comment   => row.comment,
      :staff_yob       => staff_yob(row.birth_date),
      :staff_age_range => staff_age_range(row.birth_date),
      :staff_zip       => row.zipcode
    )
  end

  produce_records(
    :staff_languages,
    staff_subtable_with_username('staff_languages')
  ) do |row|
    StaffLanguage.new(
      :staff_language_id => prefix_id(row.staff_language_id),
      :staff_id          => staff_id(row),
      :staff_lang        => row.lang_code,
      :staff_lang_oth    => row.lang_other
    )
  end

  produce_records(
    :staff_cert_trainings,
    staff_subtable_with_username('staff_cert_trainings')
  ) do |row|
    StaffCertTraining.new(
      :staff_cert_list_id  => prefix_id(row.id),
      :staff_id            => staff_id(row),
      :cert_train_type     => row.certificate_type_code,
      :cert_completed      => row.complete_code,
      :cert_date           => row.cert_date,
      :staff_bgcheck_lvl   => row.background_check_code,
      :cert_type_frequency => row.frequency,
      :cert_type_exp_date  => row.expiration_date,
      :cert_comment        => row.comment
    )
  end

  ###### EXPENSES

  produce_records(
    :staff_weekly_expenses,
    %Q{
      SELECT swe.id, swe.week_start_date, swe.rate, swe.comment, s.username, mt.*
      FROM staff_weekly_expenses swe
        INNER JOIN staff s ON swe.staff_id=s.id
        LEFT JOIN (
          SELECT staff_weekly_expense_id, SUM(hours) hours, SUM(expenses) expenses, SUM(miles) miles
          FROM management_tasks mt GROUP BY staff_weekly_expense_id
        ) mt ON swe.id=mt.staff_weekly_expense_id
    }
  ) do |row|
    StaffWeeklyExpense.new(
      :weekly_exp_id           => prefix_id(row.id),
      :staff_id                => staff_id(row),
      :week_start_date         => row.week_start_date,
      :staff_pay               => row.rate,
      :staff_hours             => row.hours,
      :staff_expenses          => row.expenses,
      :staff_miles             => row.miles,
      :weekly_expenses_comment => row.comment
    )
  end

  produce_records(
    :management_tasks
  ) do |row|
    StaffExpMngmntTasks.new(
      :staff_exp_mgmt_task_id  => prefix_id(row.id),
      :staff_weekly_expense_id => prefix_id(row.staff_weekly_expense_id),
      :mgmt_task_type          => row.task_type_code,
      :mgmt_task_type_oth      => row.task_type_other,
      :mgmt_task_hrs           => row.hours,
      :mgmt_task_comment       => row.comment
    )
  end

  ###### OUTREACH

  def self.outreach_join(table_name, options={})
    %Q{
      SELECT ot.*, ns.ssu_id#{', s.username' if options[:staff]}
      FROM #{table_name} ot
        INNER JOIN outreach_segments os ON ot.outreach_event_id=os.outreach_event_id
        INNER JOIN ncs_area_ssus ns ON os.ncs_area_id=ns.ncs_area_id
        #{'INNER JOIN staff s ON ot.staff_id=s.id' if options[:staff]}
    }
  end

  def outreach_event_id(row)
    prefix_id([row.outreach_event_id, row.ssu_id].join('_'))
  end

  produce_records(
    :outreach_events,
    %Q{
       SELECT oe.*, oe.id as outreach_event_id, ol.language_other, ns.ssu_id
       FROM outreach_events oe
         INNER JOIN outreach_segments os ON oe.id=os.outreach_event_id
         INNER JOIN ncs_area_ssus ns ON os.ncs_area_id=ns.ncs_area_id
         LEFT JOIN (
           SELECT outreach_event_id, language_other
           FROM outreach_languages WHERE language_other IS NOT NULL
         ) ol ON oe.id=ol.outreach_event_id
    }
  ) do |row|
    # see also: outreach_untailored_language_race
    is_tailored = (row.tailored_code.to_i == 2)

    Outreach.new(
      :outreach_event_id    => outreach_event_id(row),
      :outreach_event_date  => row.event_date,
      :outreach_mode        => row.mode_code,
      :outreach_mode_oth    => row.mode_other,
      :outreach_type        => row.outreach_type_code,
      :outreach_type_oth    => row.outreach_type_other,
      :outreach_tailored    => row.tailored_code,
      :outreach_lang1       => is_tailored ? row.language_specific_code : '2', # No if untailored
      :outreach_lang_oth    => row.language_other,
      :outreach_race1       => is_tailored ? row.race_specific_code : '2',     # No if untailored
      :outreach_culture1    => is_tailored ? row.culture_specific_code : '2',  # No if untailored
      :outreach_culture2    => is_tailored ? row.culture_code : '-7',          # NA if untailored
      :outreach_culture_oth => row.culture_other,
      :outreach_cost        => row.cost,
      :outreach_staffing    => row.no_of_staff,
      :outreach_eval_result => row.evaluation_result_code,
      :outreach_quantity    => row.letters_quantity.to_i + row.attendees_quantity.to_i
    )
  end

  produce_records(
    :outreach_languages,
    outreach_join('outreach_languages')
  ) do |row|
    OutreachLang2.new(
      :outreach_lang2_id => prefix_id(row.id),
      :outreach_event_id => outreach_event_id(row),
      :outreach_lang2    => row.language_code
    )
  end

  produce_records(
    :outreach_races,
    outreach_join('outreach_races')
  ) do |row|
    OutreachRace.new(
      :outreach_race_id    => prefix_id(row.id),
      :outreach_event_id   => outreach_event_id(row),
      :outreach_race2      => row.race_code,
      :outreach_race_other => row.race_other
    )
  end

  produce_records(
    :outreach_untailored_language_race,
    %q{
       SELECT oe.id, ns.ssu_id
       FROM outreach_events oe
         INNER JOIN outreach_segments os ON oe.id=os.outreach_event_id
         INNER JOIN ncs_area_ssus ns ON os.ncs_area_id=ns.ncs_area_id
       WHERE oe.tailored_code=2
    }
  ) do |row|
    id = prefix_id([row.id, 'untailored'].join('-'))

    [
      OutreachLang2.new(
        :outreach_lang2_id => id,
        :outreach_event_id => outreach_event_id(row),
        :outreach_lang2 => '1' # English
      ),
      OutreachRace.new(
        :outreach_race_id => id,
        :outreach_event_id => outreach_event_id(row),
        :outreach_race2 => '-7' # NA
      )
    ]
  end

  produce_records(
    :outreach_targets,
    outreach_join('outreach_targets')
  ) do |row|
    OutreachTarget.new(
      :outreach_target_id     => prefix_id(row.id),
      :outreach_event_id      => outreach_event_id(row),
      :outreach_target_ms     => row.target_code,
      :outreach_target_ms_oth => row.target_other
    )
  end

  produce_records(
    :outreach_evaluations,
    outreach_join('outreach_evaluations')
 ) do |row|
    OutreachEval.new(
      :outreach_event_eval_id => prefix_id(row.id),
      :outreach_event_id      => outreach_event_id(row),
      :outreach_eval          => row.target_code,
      :outreach_eval_oth      => row.target_other
    )
  end

  produce_records(
    :outreach_staff_members,
    outreach_join('outreach_staff_members', :staff => true)
  ) do |row|
    OutreachEval.new(
      :outreach_event_staff_id => prefix_id(row.id),
      :outreach_event_id       => outreach_event_id(row),
      :staff_id                => staff_id(row)
    )
  end
end

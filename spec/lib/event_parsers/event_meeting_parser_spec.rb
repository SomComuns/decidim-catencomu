# frozen_string_literal: true

require "rails_helper"

describe EventParsers::EventMeetingParser, type: :class do
  subject { described_class.new(meeting) }

  let(:meeting) { create :meeting }
  let(:json) do
    {
      start_date: meeting.start_time.strftime("%Y%m%d"),
      title: "#{meeting.participatory_space.title["ca"]}: #{meeting.title["ca"]}",
      template_id: 2
    }
  end
  let(:data) do
    {
      entity: "Event",
      action: "create",
      json: 1
    }
  end
  let(:result) do
    {
      "id" => "123"
    }
  end

  before do
    subject.result = result
  end

  it "is valid" do
    expect(subject.valid?).to eq(true)
  end

  it "returns data" do
    expect(subject.json).to eq(json)
    expect(subject.data).to eq(data.merge(json))
  end

  it "saves data" do
    expect { subject.save! }.to change(MeetingEventAssignment, :count).by(1)
  end

  context "when no result" do
    let(:result) do
      {
        "id" => ""
      }
    end

    it "is invalid" do
      expect(subject.valid?).to eq(false)
    end

    it "don't save data" do
      expect { subject.save! }.to raise_error StandardError
      expect(MeetingEventAssignment.count).to eq(0)
    end
  end
end

import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Flex, Button, Section, ProgressBar, LabeledList } from '../components';
import { Window } from '../layouts';

export const Healthscan = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window resizable>
      <Window.Content>
        <Section>
        <Flex>
          <Flex.Item width="30%" mr="3px">
            <LeftSide />
          </Flex.Item>
          <Flex.Item width="70%">
            <RightSide />
          </Flex.Item>
        </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};

const LeftSide = (props, context) => {
  const { data } = useBackend(context);
  const { name, warnings } = data

  return (
    <>
      <Section title="Subject">
        <PatientData />
        <ProgressBar />
      </Section>
      <Section title="Warnings">
        {warnings.map((warning, index) => (
          <Box key={index}>{warning.text}</Box>
        ))}
      </Section>
    </>
  )};


const PatientData = (props, context) => {
  const { data } = useBackend(context);
  const { name, warnings } = data

  return (
      <LabeledList>
        <LabeledList.Item label="Name">{name}</LabeledList.Item>
        <LabeledList.Item label="Health">
          <ProgressBar
            min="0"
            max={maxHealth}
            value={health / maxHealth}
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
          >
            {round(health, 0)}
          </ProgressBar>
        </LabeledList.Item>
        <LabeledList.Item label="Status" color={stats[stat][0]}>
          {stats[stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Temperature">
          <ProgressBar
            min="0"
            max="1000"
            value={bodytemp / 1000}
            color={tempColors[occupant.temperatureSuitability + 3]}
          >
            {round(occupant.btCelsius, 0)}&deg;C,
            {round(occupant.btFaren, 0)}&deg;F
          </ProgressBar>
        </LabeledList.Item>
        {!!occupant.hasBlood && (
          <Fragment>
            <LabeledList.Item label="Blood Level">
              <ProgressBar
                min="0"
                max={occupant.bloodMax}
                value={occupant.bloodLevel / occupant.bloodMax}
                ranges={{
                  bad: [-Infinity, 0.6],
                  average: [0.6, 0.9],
                  good: [0.6, Infinity],
                }}
              >
                {occupant.bloodPercent}%, {occupant.bloodLevel}cl
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Pulse" verticalAlign="middle">
              {occupant.pulse} BPM
            </LabeledList.Item>
          </Fragment>
        )}
      </LabeledList>
  )}

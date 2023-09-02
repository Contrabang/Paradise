import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Flex, Button, Section, ProgressBar, LabeledList, Tooltip, Icon, Table } from '../components';
import { Window } from '../layouts';
import { round } from 'common/math';
import { LabeledListItem } from '../components/LabeledList';
import { timeAgo } from '../constants';

const stats = [
  ['good', 'Alive'],
  ['average', 'Unconscious'],
  ['bad', 'Dead'],
  ['bad', 'Dead [DNR]'],
];
export const Healthscan = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window theme="medical" resizable>
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
  const { name, fatal, crit_alert } = data

  let fatal_alert = "s"; // this somehow transfers between patients, todo not working
  if(crit_alert || (fatal && fatal.length > 0)) {
    fatal_alert = (
      <>
        {crit_alert && <DiseaseBox disease={crit_alert}/>}

        {fatal && fatal.length > 0 ?
          <Section title="Fatal Injuries">
            {fatal.map((warning, index) => (
              <Box my="4px" bold key={index}>{warning.text}</Box>
              ))
            }
          </Section>
          :
          null
        }
      </>)
  }
  else {
    fatal_alert = "fuck"
  }
  return (
    <>
      <PatientData />
      {fatal_alert}
    </>
  )};

const RightSide = (props, context) => {
  const { data } = useBackend(context);
  const { brute, burn, toxin, oxygen, info, warnings, viruses, cyber_mods, local_dam } = data

  return (
    <Fragment>
      <Section title="Localized Damages">
        <Flex my="10px" grow basis="100%">
          <Flex.Item
            color="red"
            grow
            basis="100%"
            bold
            textAlign="center"
            inline
            position="relative"
          >
            {brute}
            <Tooltip content="Brute"/>
          </Flex.Item>
          <Flex.Item
            color="orange"
            grow
            basis="100%"
            bold
            textAlign="center"
            inline
            position="relative"
          >
            {burn}
            <Tooltip content="Burn"/>
          </Flex.Item>
          <Flex.Item
            color="green"
            grow
            basis="100%"
            bold
            textAlign="center"
            inline
            position="relative"
          >
            {toxin}
            <Tooltip content="Toxins"/>
          </Flex.Item>
          <Flex.Item
            color="blue"
            grow
            basis="100%"
            bold
            textAlign="center"
            inline
            position="relative"
          >
            {oxygen}
            <Tooltip content="Suffocation"/>
          </Flex.Item>
        </Flex>
        {local_dam && local_dam.length > 0 ?
          <Table m="0.5rem">
            <Table.Row px="3px" header>
              <Table.Cell>Name</Table.Cell>
              <Table.Cell>Brute <Icon name="bone" /></Table.Cell>
              <Table.Cell>Burn <Icon name="fire" /></Table.Cell>
            </Table.Row>
            {local_dam.map((warning, index) => (
            <Table.Row className="candystripe" key={index}>
              <Table.Cell p="3px">
                {warning.name}
              </Table.Cell>
              <Table.Cell color="red">
                {warning.brute}
              </Table.Cell>
              <Table.Cell color="orange">
                {warning.burn}
              </Table.Cell>
            </Table.Row>
            ))
            }
          </Table>
        :
        null
      }
      </Section>
      <Section title="Warnings">
        {warnings && warnings.length > 0 ? warnings.map((warning, index) => (
          <Box my="4px" bold key={index}>{warning.text}</Box>
        ))
        :
        <Box italic color="grey">Subject has no major health concerns.</Box>
      }
      </Section>
      <Section title="Info">
        {info.map((warning, index) => (
          <Box color={warning.color} my="4px" key={index}>{warning.text}</Box>
        ))}
      </Section>
      <Section title="Viruses">
        {viruses && viruses.length > 0 ? viruses.map((warning, index) => (
          <DiseaseBox disease={warning} key={index}/>
        ))
        :
        <Box italic color="grey">No viruses detected.</Box>
      }
      </Section>
      {cyber_mods && cyber_mods.length > 0 &&
      <Section title="Cybernetic Modifications">
        {cyber_mods.map((warning, index) => (
          <Box my="4px" key={index}>{warning}</Box>
        ))}
      </Section>
      }
    </Fragment>
  )
};


const PatientData = (props, context) => {
  const { data } = useBackend(context);
  const { name,
    maxHealth,
    health,
    bodytemp,
    bodytempF,
    stat,
    max_blood,
    blood_volume,
    blood_type,
    hasBlood,
    blood_percent,
    pulse,
    timeofdeath
  } = data

  const bloodType = "Blood type: " + blood_type
  return (
    <Section title={name}>
      <LabeledList>
        <LabeledList.Item label="Health">
          <ProgressBar.Negative
            min={-maxHealth}
            max={maxHealth}
            value={health / maxHealth}
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
          >
            {round(health, 0)}
          </ProgressBar.Negative>
        </LabeledList.Item>
        <LabeledList.Item label="Status" color={stats[stat][0]}>
          {stats[stat][1]}
        </LabeledList.Item>
        {stat >= 2 &&
          <LabeledList.Item label="ToD" color={stats[stat][0]}>
            <Box inline position="relative">
              {timeofdeath}
              <Tooltip content={"Time of Death: " + timeAgo(data.death_ticks, data.world_time)}/>
            </Box>
          </LabeledList.Item>
        }
        <LabeledList.Item label="Temp">
            {round(bodytemp, 1)}&deg;C (
            {round(bodytempF, 1)}&deg;F)
        </LabeledList.Item>
        {hasBlood && (
          <Fragment>
            <LabeledList.Item label="Blood">
              <ProgressBar
                min="0"
                max={max_blood}
                value={blood_volume / max_blood}
                ranges={{
                  bad: [-Infinity, 0.6],
                  average: [0.6, 0.9],
                  good: [0.6, Infinity],
                }}
              >
                <>
                {blood_percent}%, {blood_volume}cl
                <Tooltip content={bloodType}/>
                </>
              </ProgressBar>
            </LabeledList.Item>
            <LabeledList.Item label="Pulse" verticalAlign="middle">
              {pulse} BPM
            </LabeledList.Item>
          </Fragment>
        )}
      </LabeledList>
    </Section>
  )}

const DiseaseBox = (props, context) => {
  const { data } = useBackend(context);
  const { disease } = props;

  return (
    <Section
      title={disease.name}
    >
      <Box mb="4px" mt="-3px" color="grey">
        {disease.form}
      </Box>
      <LabeledList>
        <LabeledListItem label="Stages">
          {disease.stage}/{disease.max_stages}
        </LabeledListItem>
        <LabeledListItem label="Cure">
          {disease.cure_text}
        </LabeledListItem>
      </LabeledList>
    </Section>
  )
}

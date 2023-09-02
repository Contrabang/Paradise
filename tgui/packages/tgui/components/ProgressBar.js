import { clamp01, keyOfMatchingRange, scale, toFixed } from 'common/math';
import { classes, pureComponentHooks } from 'common/react';
import { Component } from 'inferno';
import { computeBoxClassName, computeBoxProps } from './Box';

export const ProgressBar = (props) => {
  const {
    className,
    value,
    minValue = 0,
    maxValue = 1,
    color,
    ranges = {},
    children,
    fractionDigits = 0,
    reversed = false,
    makeDefaultNegative = false,
    ...rest
  } = props;
  const contentDefaultMult = makeDefaultNegative ? -100 : 100
  const scaledValue = scale(value, minValue, maxValue);
  const hasContent = children !== undefined;
  const effectiveColor =
    color || keyOfMatchingRange(value, ranges) || 'default';
  const amount = clamp01(scaledValue) * 100
  return (
    <div
      className={classes([
        'ProgressBar',
        'ProgressBar--color--' + effectiveColor,
        className,
        computeBoxClassName(rest),
      ])}
      {...computeBoxProps(rest)}
    >
      <div
        className="ProgressBar__fill ProgressBar__fill--animated"
        style={{
          width: amount + '%',
          left: reversed ? `${100 - amount}%` : 0,
        }}
      />
      <div className="ProgressBar__content">
        {hasContent
          ? children
          : toFixed(scaledValue * contentDefaultMult, fractionDigits) + '%'}
      </div>
    </div>
  );
};

ProgressBar.defaultHooks = pureComponentHooks;

export class ProgressBarCountdown extends Component {
  constructor(props) {
    super(props);
    this.timer = null;
    this.state = {
      value: Math.max(props.current * 100, 0), // ds -> ms
    };
  }

  tick() {
    const newValue = Math.max(this.state.value + this.props.rate, 0);
    if (newValue <= 0) {
      clearInterval(this.timer);
    }
    this.setState((prevState) => {
      return {
        value: newValue,
      };
    });
  }

  componentDidMount() {
    this.timer = setInterval(() => this.tick(), this.props.rate);
  }

  componentWillUnmount() {
    clearInterval(this.timer);
  }

  render() {
    const { start, current, end, ...rest } = this.props;
    const frac = (this.state.value / 100 - start) / (end - start);
    return <ProgressBar value={frac} {...rest} />;
  }
}

ProgressBarCountdown.defaultProps = {
  rate: 1000,
};

ProgressBar.Countdown = ProgressBarCountdown;

// Has some flaws with swapping between negative and positive, but mostly works.
export const ProgressBarNegative = (props, context) => {
  const {
    minValue = -1,
    swapValue = 0,
    maxValue = 1,
    reversed = false,
    children,
    ...rest
  } = props;

  if(props.value < swapValue){
    return (
      <ProgressBar minValue={swapValue} maxValue={minValue} reversed={!reversed} makeDefaultNegative {...rest}  />
    )
  }
  return (
    <ProgressBar minValue={swapValue} maxValue={maxValue} reversed={reversed} {...rest} />
  )
  // }
}

ProgressBar.Negative = ProgressBarNegative;

import React from 'react';
import { Composition } from 'remotion';
import { PulseField } from './PulseField';
import { VIDEO } from './lib/constants';

export const RemotionRoot: React.FC = () => {
  return (
    <Composition
      id="PulseField"
      component={PulseField}
      durationInFrames={VIDEO.durationInFrames}
      fps={VIDEO.fps}
      width={VIDEO.width}
      height={VIDEO.height}
    />
  );
};

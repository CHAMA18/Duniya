import React from "react";
import { Composition } from "remotion";
import { DoppelgangerDemo } from "./components/DoppelgangerDemo";

export const RemotionRoot: React.FC = () => {
  return (
    <>
      <Composition
        id="DoppelgangerDemo"
        component={DoppelgangerDemo}
        durationInFrames={450} // 15 seconds at 30fps
        fps={30}
        width={1920}
        height={1080}
      />
    </>
  );
};

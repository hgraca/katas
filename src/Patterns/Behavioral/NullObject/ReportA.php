<?php

declare(strict_types=1);

namespace Hgraca\Katas\Patterns\Behavioral\NullObject;

final class ReportA
{
    public function printA(): void
    {
        echo "A\n";
    }

    public function printB(): void
    {
        echo "B\n";
    }

    public function printC(): void
    {
        echo "C\n";
    }
}

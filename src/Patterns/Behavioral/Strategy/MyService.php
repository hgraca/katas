<?php

declare(strict_types=1);

namespace Hgraca\Katas\Patterns\Behavioral\Strategy;

final class MyService
{
    public function run(string $name = ''): void
    {
        switch ($name) {
            case 'A':
                echo 'AAA';
                break;
            case 'B':
                echo 'BBB';
                break;
            case 'C':
                echo 'CCC';
                break;
            default:
                echo 'default';
                break;
        }
    }
}

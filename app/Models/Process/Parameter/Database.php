<?php

declare(strict_types=1);

namespace App\Models\Process\Parameter;

/**
 * @author      Andreas Knollmann
 * @copyright   2014-2026 Softwareentwicklung Andreas Knollmann
 * @license     http://www.opensource.org/licenses/mit-license.php MIT
 */
class Database extends Base
{
    protected function getServerValues(): array
    {
        return ['host' => 'databaseHost'];
    }

    protected function getServerLists(): array
    {
        return [];
    }

    protected function getComponentValues(): array
    {
        return [
            'port' => 'databasePort',
            'type' => 'databaseType',
            'version' => 'databaseVersion',
            'user' => 'databaseUser',
            'password' => 'databasePassword',
            'name' => 'databaseName',
        ];
    }

    protected function getComponentLists(): array
    {
        return [];
    }
}
